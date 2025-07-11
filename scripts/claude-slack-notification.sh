#!/bin/bash
# Claude Code Slack通知スクリプト

# 環境変数からWebhook URLを取得（セキュリティのため）
WEBHOOK_URL="${SLACK_WEBHOOK_URL}"

# パラメータを受け取る
EVENT_TYPE="${1:-Stop}"
MESSAGE="${2:-}"

# Webhook URLが設定されていない場合はエラー
if [ -z "$WEBHOOK_URL" ]; then
    echo '{"continue":true,"suppressOutput":false,"error":"SLACK_WEBHOOK_URL environment variable not set"}'
    exit 0
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

# Slack用のJSON作成
PAYLOAD=$(cat <<EOF
{
    "username": "Claude Code",
    "icon_emoji": ":claude:",
    "attachments": [
        {
            "color": "$COLOR",
            "title": "$EMOJI $TITLE",
            "text": "$DISPLAY_MSG",
            "footer": "Claude Code Hooks",
            "footer_icon": "https://www.anthropic.com/favicon.ico",
            "ts": $(date +%s),
            "fields": [
                {
                    "title": "イベント",
                    "value": "$EVENT_TYPE",
                    "short": true
                },
                {
                    "title": "時刻",
                    "value": "$TIMESTAMP",
                    "short": true
                }
            ]
        }
    ]
}
EOF
)

# Slackに送信
RESPONSE=$(curl -s -X POST \
    -H 'Content-type: application/json' \
    --data "$PAYLOAD" \
    "$WEBHOOK_URL" 2>&1)

# レスポンスを確認
if [ "$RESPONSE" = "ok" ]; then
    echo '{"continue":true,"suppressOutput":true}'
else
    echo "{\"continue\":true,\"suppressOutput\":false,\"error\":\"Slack API error: $RESPONSE\"}"
fi