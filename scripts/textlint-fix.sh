#!/bin/bash

# textlint-fix.sh - AIっぽい文章を自動修正するスクリプト
# 使用方法: ./textlint-fix.sh [ファイルパス]
# ファイルパスが指定されない場合は、すべての.mdファイルを修正

set -euo pipefail

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ディレクトリをワークスペースに変更
cd /workspace

# パラメータ処理
TARGET_FILES="${1:-**/*.md}"

echo -e "${YELLOW}textlint AI文章の自動修正を開始します...${NC}"

# textlintが利用可能か確認
if ! command -v npx &> /dev/null; then
    echo -e "${RED}エラー: npxが見つかりません。Node.jsがインストールされているか確認してください。${NC}"
    exit 1
fi

# バックアップディレクトリの作成
BACKUP_DIR="/workspace/.textlint-backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# ファイルのバックアップ
echo -e "${BLUE}変更前のファイルをバックアップしています...${NC}"
if [ "$TARGET_FILES" = "**/*.md" ]; then
    # すべてのMarkdownファイルをバックアップ
    find /workspace -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" -exec cp --parents {} "$BACKUP_DIR" \;
else
    # 特定のファイルをバックアップ
    cp "$TARGET_FILES" "$BACKUP_DIR/"
fi

# textlintで自動修正を実行
echo -e "${YELLOW}AIっぽい文章パターンを修正しています...${NC}"
if [ "$TARGET_FILES" = "**/*.md" ]; then
    # すべてのMarkdownファイルを修正
    npx textlint "${TARGET_FILES}" --fix --ignore-path .gitignore || RESULT=$?
else
    # 特定のファイルを修正
    npx textlint "$TARGET_FILES" --fix || RESULT=$?
fi

# 結果の表示
if [ "${RESULT:-0}" -eq 0 ]; then
    echo -e "${GREEN}✓ 自動修正が完了しました！${NC}"
    echo -e "${BLUE}バックアップは以下に保存されています: $BACKUP_DIR${NC}"
    
    # 変更内容の確認を促す
    echo -e "${YELLOW}ヒント: 'git diff' で変更内容を確認してください。${NC}"
    exit 0
else
    echo -e "${RED}✗ 一部のエラーは自動修正できませんでした。${NC}"
    echo -e "${YELLOW}手動での修正が必要な場合があります。${NC}"
    exit 1
fi