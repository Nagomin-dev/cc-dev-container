#!/bin/bash
set -euo pipefail
# Claude Code Slack通知スクリプト

# 環境変数からWebhook URLを取得（セキュリティのため）
WEBHOOK_URL="${SLACK_WEBHOOK_URL}"

# パラメータを受け取る
EVENT_TYPE="${1:-Stop}"
shift  # 最初のパラメータを除去
MESSAGE="$*"  # 残りのすべての引数をメッセージとして取得

# Webhook URLが設定されていない場合はエラー
if [ -z "$WEBHOOK_URL" ]; then
    echo '{"continue":true,"suppressOutput":false,"error":"SLACK_WEBHOOK_URL environment variable not set"}'
    exit 1
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
        EMOJI=":bell:"
        COLOR="warning"
        TITLE="通知"
        DEFAULT_MSG="Claude Codeからの通知があります"
        ;;
    "SubagentStop")
        EMOJI=":robot_face:"
        COLOR="good"
        TITLE="サブエージェント完了"
        DEFAULT_MSG="サブエージェントがタスクを完了しました"
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

# Slack用のJSON作成 (jqで安全にエスケープ)
PAYLOAD=$(jq -n \
    --arg username "Claude Code" \
    --arg icon_emoji ":claude:" \
    --arg color "$COLOR" \
    --arg title "$EMOJI $TITLE" \
    --arg text "$DISPLAY_MSG" \
    --arg footer "Claude Code Hooks" \
    --arg footer_icon "https://www.anthropic.com/favicon.ico" \
    --arg event_type "$EVENT_TYPE" \
    --arg timestamp "$TIMESTAMP" \
    --argjson ts "$(date +%s)" \
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
                fields: [
                    {
                        title: "イベント",
                        value: $event_type,
                        short: true
                    },
                    {
                        title: "時刻",
                        value: $timestamp,
                        short: true
                    }
                ]
            }
        ]
    }')

# Slackに送信 (HTTPステータスコードとレスポンスボディを別々に取得)
HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -H 'Content-type: application/json' \
    --data "$PAYLOAD" \
    "$WEBHOOK_URL" 2>&1)

# curlの終了コードを確認
CURL_EXIT_CODE=$?
if [ $CURL_EXIT_CODE -ne 0 ]; then
    echo "{\"continue\":true,\"suppressOutput\":false,\"error\":\"Network error: curl exit code $CURL_EXIT_CODE\"}"
    exit 1
fi

# レスポンスボディとHTTPステータスコードを分離
RESPONSE_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tail -n1)

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
echo '{"continue":true,"suppressOutput":true}'