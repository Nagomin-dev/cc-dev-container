#!/bin/bash
set -euo pipefail
# Claude Code Slack通知スクリプト
# stdinからJSON入力を受け取り、詳細な通知を送信

# 環境変数からWebhook URLを取得（セキュリティのため）
WEBHOOK_URL="${SLACK_WEBHOOK_URL}"

# デバッグモード
DEBUG="${SLACK_NOTIFICATION_DEBUG:-0}"

# ログファイル（デバッグ用）
LOG_FILE="/tmp/claude-slack-notification.log"

# ログローテーション設定
MAX_LOG_SIZE="${SLACK_NOTIFICATION_MAX_LOG_SIZE:-10485760}"  # デフォルト: 10MB

# ログローテーション関数
rotate_log() {
    if [ -f "$LOG_FILE" ]; then
        local file_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
        if [ "$file_size" -gt "$MAX_LOG_SIZE" ]; then
            # 古いログをバックアップして新しいログファイルを開始
            mv "$LOG_FILE" "${LOG_FILE}.old"
            touch "$LOG_FILE"
        fi
    fi
}

# デバッグモード時のみログローテーションを実行
if [ "$DEBUG" = "1" ]; then
    rotate_log
fi

# デバッグログ関数
debug_log() {
    if [ "$DEBUG" = "1" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
    fi
}

# jqコマンドの存在確認
command -v jq >/dev/null 2>&1 || {
  echo '{"continue":true,"suppressOutput":false,"error":"jq not installed"}'
  exit 1
}

# Webhook URLが設定されていない場合はエラー
if [ -z "$WEBHOOK_URL" ]; then
    echo '{"continue":true,"suppressOutput":false,"error":"SLACK_WEBHOOK_URL environment variable not set"}'
    exit 1
fi

# 引数からイベントタイプを取得
EVENT_TYPE="${1:-Stop}"
shift || true
MESSAGE="$*"

debug_log "Script called with EVENT_TYPE: $EVENT_TYPE, MESSAGE: $MESSAGE"

# JSON入力を試みる（Hooksから呼ばれた場合）
JSON_INPUT=""
if read -t 0; then
    # stdinにデータがある場合、JSON入力を読み取る
    debug_log "Reading JSON from stdin"
    if IFS= read -r JSON_INPUT; then
        debug_log "Received JSON: $JSON_INPUT"

        # JSONからイベント情報を抽出（引数で渡されたイベントタイプを優先）
        MESSAGE=$(echo "$JSON_INPUT" | jq -r '.message // empty') || MESSAGE=""
        SESSION_ID=$(echo "$JSON_INPUT" | jq -r '.session_id // empty') || SESSION_ID=""
        TRANSCRIPT_PATH=$(echo "$JSON_INPUT" | jq -r '.transcript_path // empty') || TRANSCRIPT_PATH=""

        # Notificationイベントの特別処理
        if [ "$EVENT_TYPE" = "Notification" ] && [ -n "$MESSAGE" ]; then
            # アイドル通知のフィルタリング
            if [[ "$MESSAGE" =~ "waiting for your input" ]] || [[ "$MESSAGE" =~ "idle for" ]]; then
                # アイドル通知を無効化する環境変数
                if [ "${SLACK_NOTIFICATION_IGNORE_IDLE:-1}" = "1" ]; then
                    debug_log "Ignoring idle notification: $MESSAGE"
                    echo '{"continue":true,"suppressOutput":true}'
                    exit 0
                fi
            fi
            # タスク完了通知のフィルタリング（確認待ちの場合など）
            if [[ "$MESSAGE" =~ "Task completed" ]] || [[ "$MESSAGE" =~ "successfully" ]]; then
                # タスク完了通知を無視する場合（Stopイベントと重複するため）
                if [ "${SLACK_NOTIFICATION_IGNORE_TASK_COMPLETION:-0}" = "1" ]; then
                    debug_log "Ignoring task completion notification: $MESSAGE"
                    echo '{"continue":true,"suppressOutput":true}'
                    exit 0
                fi
            fi
        fi
    fi
else
    debug_log "No JSON input detected, using command-line mode"
fi

# セッションIDの短縮版（末尾4文字）
SESSION_ID_SHORT=""
if [ -n "${SESSION_ID:-}" ]; then
    SESSION_ID_SHORT="${SESSION_ID: -4}"
fi

# イベントタイプに応じた設定
case "$EVENT_TYPE" in
    "Stop")
        EMOJI=":white_check_mark:"
        COLOR="good"
        TITLE="タスク完了"
        DEFAULT_MSG="Claude Codeがタスクを完了しました"
        ;;
    "Notification")
        # メッセージ内容に基づいて通知をカスタマイズ
        if [[ "${MESSAGE:-}" =~ "permission" ]]; then
            EMOJI=":warning:"
            COLOR="warning"
            TITLE="許可が必要"
        elif [[ "${MESSAGE:-}" =~ "waiting" ]] || [[ "${MESSAGE:-}" =~ "idle" ]]; then
            EMOJI=":hourglass:"
            COLOR="#808080"
            TITLE="待機中"
        elif [[ "${MESSAGE:-}" =~ "Task completed" ]] || [[ "${MESSAGE:-}" =~ "successfully" ]]; then
            EMOJI=":clipboard:"
            COLOR="#439FE0"
            TITLE="確認完了"
        else
            EMOJI=":bell:"
            COLOR="warning"
            TITLE="通知"
        fi
        DEFAULT_MSG="${MESSAGE:-Claude Codeからの通知があります}"
        ;;
    "SubagentStop")
        EMOJI=":robot_face:"
        COLOR="good"
        TITLE="サブエージェント完了"
        DEFAULT_MSG="サブエージェントがタスクを完了しました"
        ;;
    "PostToolUse")
        EMOJI=":wrench:"
        COLOR="#439FE0"
        TITLE="ツール使用"
        DEFAULT_MSG="ツールが使用されました"
        ;;
    *)
        EMOJI=":speech_balloon:"
        COLOR="#439FE0"
        TITLE="Claude Code"
        DEFAULT_MSG="イベント: $EVENT_TYPE"
        ;;
esac

# メッセージの設定
DISPLAY_MSG="${MESSAGE:-$DEFAULT_MSG}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

debug_log "Final EVENT_TYPE: $EVENT_TYPE, DISPLAY_MSG: $DISPLAY_MSG"

# Slack用のJSON作成 (詳細情報を含む)
FIELDS='[
    {
        "title": "イベント",
        "value": "'"$EVENT_TYPE"'",
        "short": true
    },
    {
        "title": "時刻",
        "value": "'"$TIMESTAMP"'",
        "short": true
    }'

# セッションIDがある場合は追加
if [ -n "$SESSION_ID_SHORT" ]; then
    FIELDS="${FIELDS}"',
    {
        "title": "セッション",
        "value": "#'"$SESSION_ID_SHORT"'",
        "short": true
    }'
fi

FIELDS="${FIELDS}"']'

# Slackペイロードの作成
PAYLOAD=$(jq -n \
    --arg username "Claude Code" \
    --arg icon_emoji ":claude:" \
    --arg color "$COLOR" \
    --arg title "$EMOJI $TITLE" \
    --arg text "$DISPLAY_MSG" \
    --arg footer "Claude Code Hooks" \
    --arg footer_icon "https://www.anthropic.com/favicon.ico" \
    --argjson ts "$(date +%s)" \
    --argjson fields "$FIELDS" \
    '{
        username: $username,
        icon_emoji: $icon_emoji,
        attachments: [
            {
                color: $color,
                title: $title,
                text: $text,
                footer: $footer,
                footer_icon: $footer_icon,
                ts: $ts,
                fields: $fields
            }
        ]
    }')

debug_log "Sending payload: $PAYLOAD"

# Slackに送信 (HTTPステータスコードとレスポンスボディを別々に取得)
HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    --max-time 30 \
    --connect-timeout 10 \
    -H 'Content-type: application/json' \
    --data "$PAYLOAD" \
    "$WEBHOOK_URL" 2>&1)

# curlの終了コードを確認
CURL_EXIT_CODE=$?
if [ $CURL_EXIT_CODE -ne 0 ]; then
    debug_log "Curl failed with exit code: $CURL_EXIT_CODE"
    echo "{\"continue\":true,\"suppressOutput\":false,\"error\":\"Network error: curl exit code $CURL_EXIT_CODE\"}"
    exit 1
fi

# レスポンスボディとHTTPステータスコードを分離
RESPONSE_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tail -n1)

debug_log "HTTP Status: $HTTP_STATUS, Response: $RESPONSE_BODY"

# HTTPステータスコードが2xxでない場合はエラー
if [[ ! "$HTTP_STATUS" =~ ^2[0-9][0-9]$ ]]; then
    echo "{\"continue\":true,\"suppressOutput\":false,\"error\":\"HTTP error: status $HTTP_STATUS, response: $RESPONSE_BODY\"}"
    exit 1
fi

# レスポンスボディが"ok"でない場合はエラー
if [ "$RESPONSE_BODY" != "ok" ]; then
    echo "{\"continue\":true,\"suppressOutput\":false,\"error\":\"Slack API error: $RESPONSE_BODY\"}"
    exit 1
fi

# 成功
debug_log "Notification sent successfully"
echo '{"continue":true,"suppressOutput":true}'
