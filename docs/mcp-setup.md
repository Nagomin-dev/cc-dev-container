# MCP（Model Context Protocol）サーバーセットアップガイド

このガイドでは、Claude Code Dev Container環境でのMCPサーバーの設定と使用方法について説明します。

## 概要

Model Context Protocol（MCP）は、LLMが外部ツールやデータソースと安全に対話するためのオープンプロトコルです。このDev Container環境には、MCPサーバーの統合があらかじめ設定されています。

## 自動セットアップ

Dev Containerを起動すると、以下が自動的に実行されます：

1. MCPサーバー関連のnpmパッケージのインストール
2. MCPキャッシュディレクトリの作成
3. `.mcp.local.json`テンプレートの生成（存在しない場合）

**注意**: Git MCPサーバーを使用するには、`@modelcontextprotocol/server-git`パッケージが必要です。現在のpackage.jsonには含まれていないため、以下のコマンドでインストールしてください：

```bash
npm install --save-dev @modelcontextprotocol/server-git
```

## 設定ファイル

### `.mcp.json`（共有設定）

プロジェクト全体で共有されるMCPサーバー設定です。デフォルトで以下が含まれています：

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "node",
      "args": ["node_modules/@modelcontextprotocol/server-filesystem/dist/index.js", "/workspace"],
      "config": {
        "allowedPaths": ["/workspace"],
        "disallowedOperations": ["write", "delete", "rename"],
        "allowSymlinks": false
      }
    }
  }
}
```

### `.mcp.local.json`（個人設定）

個人的な設定やAPIキーを含む設定ファイルです。このファイルは`.gitignore`に含まれているため、Gitにコミットされません。

例：GitHub MCPサーバーの設定（公式実装）
```json
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
```

**注意**: 従来の`@modelcontextprotocol/server-github`パッケージは非推奨となりました。GitHubの公式MCPサーバー実装（[@github/mcp-server-github](https://github.com/github/github-mcp-server)）の使用を推奨します。

## 利用可能なMCPサーバー

### 1. Filesystem サーバー

ファイルシステムへの安全なアクセスを提供します。

- **パス**: `/workspace`ディレクトリのみアクセス可能
- **操作**: 読み取り専用（書き込み、削除、リネームは無効）
- **用途**: ファイルの参照、内容の確認

### 2. GitHub サーバー（オプション）

GitHub APIとの統合を提供します。

- **公式実装**: [@github/mcp-server-github](https://github.com/github/github-mcp-server)
- **設定**: `.mcp.local.json`でGitHubトークンの設定が必要
- **機能**: リポジトリ管理、ファイル操作、Issue/PR操作、検索、ブランチ作成
- **環境変数**: `GITHUB_PERSONAL_ACCESS_TOKEN`を設定
- **注意**: 従来の`@modelcontextprotocol/server-github`は非推奨

### 3. PostgreSQL/SQLite サーバー（オプション）

データベースへのアクセスを提供します。

- **インストール**: 必要に応じて個別にインストール
- **設定**: `.mcp.local.json`で接続情報の設定が必要
- **例**: `@modelcontextprotocol/server-postgres`、`@modelcontextprotocol/server-sqlite`

## MCPサーバーの管理

### サーバー一覧の確認

```bash
claude mcp list
```

### 新しいサーバーの追加

```bash
claude mcp add
```

対話的にサーバー情報を入力できます。

### サーバーの詳細確認

```bash
claude mcp get <server-name>
```

### 動作確認

```bash
# MCPサーバーの動作テスト
./scripts/mcp-test.sh
```

## カスタムMCPサーバーの作成

独自のMCPサーバーを作成する場合：

1. MCPサーバーを実装（TypeScriptまたはPython）
2. `.mcp.local.json`に設定を追加
3. 必要な依存関係を`package.json`に追加

例：カスタムAPIサーバー
```json
{
  "mcpServers": {
    "my-api": {
      "type": "sse",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${MY_API_KEY}"
      }
    }
  }
}
```

## トラブルシューティング

### MCPサーバーが認識されない

1. `npm install`が正常に完了したか確認
2. `.mcp.json`のJSON構文が正しいか確認
3. `claude mcp list`でサーバーが表示されるか確認

### 認証エラー

1. 環境変数が正しく設定されているか確認
2. APIキーやトークンの有効期限を確認
3. `.mcp.local.json`の設定を確認

### パフォーマンスの問題

1. MCPキャッシュディレクトリ（`/home/node/.mcp-cache`）をクリア
2. 不要なMCPサーバーを無効化
3. サーバーのログを確認

## セキュリティのベストプラクティス

1. **APIキーの管理**
   - APIキーは必ず`.mcp.local.json`または環境変数で管理
   - 直接コードにハードコードしない

2. **アクセス制限**
   - filesystemサーバーは必要最小限のパスのみ許可
   - 書き込み操作は慎重に有効化

3. **定期的な更新**
   - MCPサーバーパッケージを定期的に更新
   - セキュリティパッチの適用

## 参考リンク

- [Model Context Protocol公式サイト](https://modelcontextprotocol.io/)
- [MCP仕様書](https://modelcontextprotocol.io/specification)
- [MCPサーバー実装例](https://github.com/modelcontextprotocol/servers)
