#!/bin/bash

# textlint-check.sh - AIっぽい文章をチェックするスクリプト
# 使用方法: ./textlint-check.sh [ファイルパス]
# ファイルパスが指定されない場合は、すべての.mdファイルをチェック

set -euo pipefail

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ディレクトリをワークスペースに変更
cd /workspace

# パラメータ処理
TARGET_FILES="${1:-**/*.md}"

echo -e "${YELLOW}textlint AI文章チェックを開始します...${NC}"

# textlintが利用可能か確認
if ! command -v npx &> /dev/null; then
    echo -e "${RED}エラー: npxが見つかりません。Node.jsがインストールされているか確認してください。${NC}"
    exit 1
fi

# textlintを実行
if [ "$TARGET_FILES" = "**/*.md" ]; then
    # すべてのMarkdownファイルをチェック
    echo -e "${YELLOW}すべてのMarkdownファイルをチェックしています...${NC}"
    npx textlint "${TARGET_FILES}" --ignore-path .gitignore || RESULT=$?
else
    # 特定のファイルをチェック
    echo -e "${YELLOW}ファイル: $TARGET_FILES をチェックしています...${NC}"
    npx textlint "$TARGET_FILES" || RESULT=$?
fi

# 結果の表示
if [ "${RESULT:-0}" -eq 0 ]; then
    echo -e "${GREEN}✓ AIっぽい文章パターンは検出されませんでした！${NC}"
    exit 0
else
    echo -e "${RED}✗ AIっぽい文章パターンが検出されました。${NC}"
    echo -e "${YELLOW}ヒント: 'npm run textlint:fix' または './scripts/textlint-fix.sh' で自動修正を試してください。${NC}"
    exit 1
fi