#!/bin/bash

# MCPサーバーテストスクリプト
# MCPサーバーの動作確認を行います

set -e

echo "🧪 MCPサーバーのテストを開始します..."
echo ""

# 色付き出力用の定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# MCPサーバー設定ファイルの確認
echo "📋 設定ファイルの確認..."
if [ -f "/workspace/.mcp.json" ]; then
    echo -e "${GREEN}✓${NC} .mcp.json が見つかりました"
else
    echo -e "${RED}✗${NC} .mcp.json が見つかりません"
    exit 1
fi

if [ -f "/workspace/.mcp.local.json" ]; then
    echo -e "${GREEN}✓${NC} .mcp.local.json が見つかりました"
else
    echo -e "${YELLOW}⚠${NC} .mcp.local.json が見つかりません（オプション）"
fi

# Node.js環境の確認
echo ""
echo "🔍 Node.js環境の確認..."
node_version=$(node --version)
npm_version=$(npm --version)
echo -e "${GREEN}✓${NC} Node.js: $node_version"
echo -e "${GREEN}✓${NC} npm: $npm_version"

# MCP依存関係の確認
echo ""
echo "📦 MCP依存関係の確認..."
cd /workspace

# 必須パッケージ
required_packages=(
    "@modelcontextprotocol/sdk"
    "@modelcontextprotocol/server-filesystem"
)

missing_packages=()
for package in "${required_packages[@]}"; do
    if npm list "$package" --depth=0 >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $package がインストールされています"
    else
        echo -e "${RED}✗${NC} $package が見つかりません"
        missing_packages+=("$package")
    fi
done

# オプションパッケージ
optional_packages=(
    "@modelcontextprotocol/server-postgres"
    "@modelcontextprotocol/server-sqlite"
)

echo ""
echo "📦 オプションパッケージの確認..."
for package in "${optional_packages[@]}"; do
    if npm list "$package" --depth=0 >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $package がインストールされています"
    else
        echo -e "${YELLOW}○${NC} $package は未インストール（オプション）"
    fi
done

# MCPサーバーの基本動作確認
echo ""
echo "🚀 MCPサーバーの基本動作確認..."

# スタートアップテストの失敗を追跡する変数
startup_failed=false

# filesystemサーバーのテスト
echo "  filesystem サーバーのテスト..."
if [ -f "node_modules/@modelcontextprotocol/server-filesystem/dist/index.js" ]; then
    # サーバーが起動できるか確認（すぐに終了）
    timeout 2s node node_modules/@modelcontextprotocol/server-filesystem/dist/index.js /workspace --help >/dev/null 2>&1
    exit_code=$?

    if [ $exit_code -eq 0 ] || [ $exit_code -eq 124 ]; then
        # exit code 0 = success, 124 = timeout (expected for a running server)
        echo -e "  ${GREEN}✓${NC} filesystem サーバーは正常に動作可能です"
    else
        echo -e "  ${RED}✗${NC} filesystem サーバーの起動に失敗しました (exit code: $exit_code)"
        startup_failed=true
    fi
else
    echo -e "  ${RED}✗${NC} filesystem サーバーが見つかりません"
    startup_failed=true
fi


# テスト結果のサマリー
echo ""
echo "📊 テスト結果のサマリー"
echo "================================"

if [ ${#missing_packages[@]} -eq 0 ] && [ "$startup_failed" = false ]; then
    echo -e "${GREEN}✅ すべての必須パッケージがインストールされ、MCPサーバーは正常に動作可能です${NC}"
    echo ""
    echo "MCPサーバーを使用する準備ができています！"
    echo ""
    echo "次のコマンドで設定を確認してください:"
    echo "  claude mcp list"
    echo ""
    echo "新しいサーバーを追加するには:"
    echo "  claude mcp add"
    exit 0
else
    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo -e "${RED}❌ 一部の必須パッケージが不足しています${NC}"
    fi
    if [ "$startup_failed" = true ]; then
        echo -e "${RED}❌ MCPサーバーの起動テストに失敗しました${NC}"
    fi
    echo ""
    echo "以下のコマンドで依存関係をインストールしてください:"
    echo "  npm install"
    exit 1
fi
