# /project:mcp-add

新しいMCPサーバーを対話的に追加します。

## 使用方法

```
/project:mcp-add
```

## 動作

1. MCPサーバーのタイプを選択（stdio、sse、http）
2. サーバー名を入力
3. 必要な設定情報を入力
4. `.mcp.local.json`に設定を追加

## サポートされるサーバータイプ

- **stdio**: ローカルプロセスとして実行
- **sse**: Server-Sent Events経由で接続
- **http**: HTTP API経由で接続

## 例

GitHub MCPサーバーを追加する場合（公式実装）：
1. タイプ: stdio
2. 名前: github
3. コマンド: npx
4. 引数: -y @github/mcp-server-github
5. 環境変数: GITHUB_PERSONAL_ACCESS_TOKEN（GitHubトークン）

注意: 従来の`@modelcontextprotocol/server-github`は非推奨となりました。
