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

# プロジェクトルートディレクトリを動的に検出
# 方法1: gitリポジトリのルートを探す
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)

# 方法2: gitが使えない場合は、スクリプトの場所から推測
if [ -z "$PROJECT_ROOT" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # scriptsディレクトリの親がプロジェクトルート
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# プロジェクトルートに移動
cd "$PROJECT_ROOT"

# RESULT変数を初期化
RESULT=0

# パラメータ処理
TARGET_FILES="${1:-**/*.md}"

echo -e "${YELLOW}textlint AI文章の自動修正を開始します...${NC}"

# textlintが利用可能か確認
if ! command -v npx &> /dev/null; then
    echo -e "${RED}エラー: npxが見つかりません。Node.jsがインストールされているか確認してください。${NC}"
    exit 1
fi

# バックアップディレクトリの作成
BACKUP_DIR="$PROJECT_ROOT/.textlint-backup/$(date +%Y%m%d_%H%M%S)"
if ! mkdir -p "$BACKUP_DIR"; then
    echo -e "${RED}エラー: バックアップディレクトリを作成できませんでした: $BACKUP_DIR${NC}"
    exit 1
fi

# ファイルのバックアップ
echo -e "${BLUE}変更前のファイルをバックアップしています...${NC}"

# バックアップ関数（ディレクトリ構造を保持）
backup_file() {
    local file="$1"
    local relative_path="${file#$PROJECT_ROOT/}"
    local backup_path="$BACKUP_DIR/$relative_path"
    local backup_dir="$(dirname "$backup_path")"
    
    # バックアップ先のディレクトリを作成
    mkdir -p "$backup_dir"
    
    # ファイルをコピー
    if ! cp "$file" "$backup_path" 2>/dev/null; then
        echo -e "${YELLOW}警告: ファイルのバックアップに失敗しました: $file${NC}"
        return 1
    fi
    return 0
}

if [ "$TARGET_FILES" = "**/*.md" ]; then
    # すべてのMarkdownファイルをバックアップ
    backup_count=0
    fail_count=0
    while IFS= read -r -d '' file; do
        if backup_file "$file"; then
            ((backup_count++))
        else
            ((fail_count++))
        fi
    done < <(find "$PROJECT_ROOT" -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" -print0)
    
    if [ $backup_count -gt 0 ]; then
        echo -e "${GREEN}${backup_count}個のファイルをバックアップしました${NC}"
    fi
    if [ $fail_count -gt 0 ]; then
        echo -e "${YELLOW}警告: ${fail_count}個のファイルのバックアップに失敗しました${NC}"
    fi
else
    # 特定のファイルまたはディレクトリをバックアップ
    if [ -f "$TARGET_FILES" ]; then
        # 単一ファイルの場合
        if ! backup_file "$TARGET_FILES"; then
            echo -e "${RED}エラー: ファイルのバックアップに失敗しました: $TARGET_FILES${NC}"
            exit 1
        fi
    elif [ -d "$TARGET_FILES" ]; then
        # ディレクトリの場合
        backup_count=0
        fail_count=0
        while IFS= read -r -d '' file; do
            if backup_file "$file"; then
                ((backup_count++))
            else
                ((fail_count++))
            fi
        done < <(find "$TARGET_FILES" -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" -print0)
        
        if [ $backup_count -eq 0 ] && [ $fail_count -eq 0 ]; then
            echo -e "${YELLOW}警告: 指定されたディレクトリにMarkdownファイルが見つかりません: $TARGET_FILES${NC}"
        else
            if [ $backup_count -gt 0 ]; then
                echo -e "${GREEN}${backup_count}個のファイルをバックアップしました${NC}"
            fi
            if [ $fail_count -gt 0 ]; then
                echo -e "${YELLOW}警告: ${fail_count}個のファイルのバックアップに失敗しました${NC}"
            fi
        fi
    else
        # ワイルドカードパターンまたは複数ファイルの場合
        backup_count=0
        fail_count=0
        for pattern in $TARGET_FILES; do
            # globパターンを展開
            shopt -s nullglob
            files=($pattern)
            shopt -u nullglob
            
            if [ ${#files[@]} -eq 0 ]; then
                echo -e "${YELLOW}警告: パターンに一致するファイルが見つかりません: $pattern${NC}"
            else
                for file in "${files[@]}"; do
                    if [ -f "$file" ] && [[ "$file" == *.md ]]; then
                        if backup_file "$file"; then
                            ((backup_count++))
                        else
                            ((fail_count++))
                        fi
                    fi
                done
            fi
        done
        
        if [ $backup_count -eq 0 ] && [ $fail_count -eq 0 ]; then
            echo -e "${RED}エラー: 指定されたファイルが見つかりません: $TARGET_FILES${NC}"
            exit 1
        else
            if [ $backup_count -gt 0 ]; then
                echo -e "${GREEN}${backup_count}個のファイルをバックアップしました${NC}"
            fi
            if [ $fail_count -gt 0 ]; then
                echo -e "${YELLOW}警告: ${fail_count}個のファイルのバックアップに失敗しました${NC}"
            fi
        fi
    fi
fi

# textlintで自動修正を実行
echo -e "${YELLOW}AIっぽい文章パターンを修正しています...${NC}"
if [ "$TARGET_FILES" = "**/*.md" ]; then
    # すべてのMarkdownファイルを修正 (findを使用してglob展開の問題を回避)
    find . -name "*.md" -type f ! -path "./node_modules/*" ! -path "./.git/*" -print0 | xargs -0 npx textlint --fix --ignore-path .gitignore || RESULT=$?
elif [ -f "$TARGET_FILES" ]; then
    # 単一ファイルを修正
    npx textlint "$TARGET_FILES" --fix || RESULT=$?
elif [ -d "$TARGET_FILES" ]; then
    # ディレクトリ内のMarkdownファイルを修正
    find "$TARGET_FILES" -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" -print0 | xargs -0 npx textlint --fix --ignore-path .gitignore || RESULT=$?
else
    # ワイルドカードパターンまたは複数ファイルの場合
    # スペースを含むファイル名に対応するため、一時的にIFSを変更
    OLD_IFS="$IFS"
    IFS=$'\n'
    
    # globパターンを展開
    shopt -s nullglob
    files=($TARGET_FILES)
    shopt -u nullglob
    
    IFS="$OLD_IFS"
    
    if [ ${#files[@]} -eq 0 ]; then
        echo -e "${RED}エラー: 指定されたファイルが見つかりません: $TARGET_FILES${NC}"
        exit 1
    fi
    
    # 各ファイルに対してtextlintを実行
    for file in "${files[@]}"; do
        if [ -f "$file" ] && [[ "$file" == *.md ]]; then
            npx textlint "$file" --fix || RESULT=$?
        fi
    done
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