#!/bin/bash

# MCPセットアップスクリプト
# このスクリプトはdevcontainer作成時に自動実行されます

set -e

echo "🔧 MCPサーバーのセットアップを開始します..."

# MCP_CACHE_DIRの検証
if [ -z "$MCP_CACHE_DIR" ]; then
    echo "⚠️  警告: MCP_CACHE_DIR環境変数が設定されていません"
    echo "デフォルト値を使用します: /home/vscode/.mcp"
    MCP_CACHE_DIR="/home/vscode/.mcp"
fi

# MCPキャッシュディレクトリの作成
if [ ! -d "$MCP_CACHE_DIR" ]; then
    mkdir -p "$MCP_CACHE_DIR"
    echo "✅ MCPキャッシュディレクトリを作成しました: $MCP_CACHE_DIR"
fi

# .mcp.local.jsonの存在確認
if [ ! -f "/workspace/.mcp.local.json" ]; then
    echo "📝 .mcp.local.jsonのテンプレートを作成します..."
    cat > /workspace/.mcp.local.json <<'EOF'
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@github/mcp-server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
EOF
    echo "✅ .mcp.local.jsonのテンプレートを作成しました"
    echo "⚠️  GitHubサーバーを使用する場合は、.mcp.local.jsonを編集してください"
fi

# MCPサーバーの依存関係確認
echo "📦 MCP依存関係の確認..."
if [ -f "/workspace/package-lock.json" ]; then
    # package-lock.jsonがある場合はnpm ciを使用
    cd /workspace && npm ci --silent
else
    # ない場合はnpm installを使用
    cd /workspace && npm install --silent
fi

echo "✅ MCPサーバーのセットアップが完了しました！"
echo ""
echo "📌 次のステップ:"
echo "  1. Claude Codeで 'claude mcp list' を実行して設定を確認"
echo "  2. 必要に応じて .mcp.local.json を編集"
echo "  3. 'claude mcp add' で新しいサーバーを追加"
echo ""
echo "詳細は /workspace/docs/mcp-setup.md を参照してください"
