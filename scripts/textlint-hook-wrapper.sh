#!/bin/bash

# textlint-hook-wrapper.sh - Claude Code PostToolUse hook用のラッパースクリプト
# stdinからJSONを受け取り、Markdownファイルが編集された場合にtextlintを実行

set -euo pipefail

# jqコマンドの存在確認
command -v jq >/dev/null 2>&1 || {
  echo '{"continue":true,"suppressOutput":false,"error":"jq not installed"}'
  exit 1
}

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# stdinからJSONを読み取る
JSON_INPUT=$(cat)

# JSON入力をログに記録（デバッグ用、本番では削除）
# echo "Received JSON: $JSON_INPUT" >> /tmp/textlint-hook.log

# jqを使用してJSONを解析
TOOL_NAME=$(echo "$JSON_INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$JSON_INPUT" | jq -r '.tool_input.file_path // empty')

# ツール名がEdit、Write、MultiEditでない場合は何もしない
if [[ ! "$TOOL_NAME" =~ ^(Edit|Write|MultiEdit)$ ]]; then
    echo '{"continue":true,"suppressOutput":true}'
    exit 0
fi

# ファイルパスが空の場合は何もしない
if [ -z "$FILE_PATH" ]; then
    echo '{"continue":true,"suppressOutput":true}'
    exit 0
fi

# Markdownファイル（.md）でない場合は何もしない
if [[ ! "$FILE_PATH" =~ \.md$ ]]; then
    echo '{"continue":true,"suppressOutput":true}'
    exit 0
fi

# ファイルが存在するか確認
if [ ! -f "$FILE_PATH" ]; then
    echo '{"continue":true,"suppressOutput":true}'
    exit 0
fi

# textlint-check.shを実行
echo "textlint AI文章チェック: $FILE_PATH" >&2
if "$SCRIPT_DIR/textlint-check.sh" "$FILE_PATH" >&2; then
    # 成功時
    echo '{"continue":true,"suppressOutput":true}'
    exit 0
else
    # エラー時（AIっぽい文章が検出された）
    # エラーメッセージはstderrに出力されているので、continueはtrueのまま
    echo '{"continue":true,"suppressOutput":false}'
    exit 0
fi
