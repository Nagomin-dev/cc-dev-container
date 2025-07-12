# /project:mcp-list

設定されているMCPサーバーの一覧を表示します。

## 使用方法

```
/project:mcp-list
```

## 動作

1. `.mcp.json`の共有設定を読み込み
2. `.mcp.local.json`の個人設定を読み込み（存在する場合）
3. すべてのMCPサーバーを一覧表示
4. 各サーバーの状態を確認

## 表示内容

- サーバー名
- タイプ（stdio、sse、http）
- 状態（利用可能、設定エラーなど）
- 簡単な説明

## 関連コマンド

- `/project:mcp-add` - 新しいMCPサーバーを追加
- `/project:mcp-test` - MCPサーバーの動作確認
