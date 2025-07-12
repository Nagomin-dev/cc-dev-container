# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

このリポジトリは、Claude Code用のDev Container環境を提供します。VS CodeのRemote - Containers拡張機能を使用して、一貫した開発環境を構築できます。Slack通知機能を含む、Claude Code Hooksが設定されています。

## アーキテクチャと構造

### ディレクトリ構造

```plaintext
/workspace/
├── .claude/
│   ├── commands/             # カスタムスラッシュコマンド
│   │   ├── check-ai-writing.md # /project:check-ai-writing
│   │   ├── create-command.md # /project:create-command
│   │   ├── edit-command.md   # /project:edit-command
│   │   ├── fix-ai-writing.md # /project:fix-ai-writing
│   │   └── git-commit.md     # /project:git-commit
│   ├── settings.json         # チーム共有のClaude Code設定
│   └── settings.local.json   # 個人設定（Gitで無視）
├── .devcontainer/
│   ├── devcontainer.json     # VS Code用のコンテナ設定
│   ├── Dockerfile            # Node.js 20ベースの開発環境
│   ├── init-firewall.sh      # セキュリティのためのファイアウォール設定
│   ├── install-extensions.sh # VSCodeフォーク拡張機能インストールスクリプト
│   └── extensions/           # VSCodeフォーク拡張機能のVSIXファイル格納ディレクトリ
├── docs/                     # ドキュメント
│   ├── textlint-setup.md     # textlintセットアップガイド
│   └── mcp-setup.md          # MCPサーバーセットアップガイド
├── scripts/
│   ├── claude-slack-notification.sh  # Slack通知スクリプト
│   ├── textlint-check.sh     # AI文章チェックスクリプト
│   ├── textlint-fix.sh       # AI文章自動修正スクリプト
│   ├── mcp-setup.sh          # MCPサーバー初期設定スクリプト
│   └── mcp-test.sh           # MCPサーバー動作確認スクリプト
├── .gitignore                # Git除外設定
├── .mcp.json                 # MCPサーバー共有設定
├── .mcp.local.json           # MCPサーバー個人設定（Gitで無視）
├── .textlintrc.json          # textlint設定
├── CLAUDE.md                 # このファイル
├── claude-slack-setup.md     # Slack通知セットアップガイド
└── package.json              # Node.js依存関係
```

### 主要コンポーネント

- **Dev Container設定** (.devcontainer/)
  - `devcontainer.json`: VS Code用のコンテナ設定
  - `Dockerfile`: Node.js 20ベースの開発環境
  - `init-firewall.sh`: セキュリティのためのファイアウォール設定スクリプト

- **Claude Code設定** (.claude/)
  - `settings.json`: チーム共有のhooks設定
  - `settings.local.json`: 個人的な設定（Webhook URLなど）

- **スクリプト** (scripts/)
  - `claude-slack-notification.sh`: Slack通知を送信するスクリプト
  - `textlint-check.sh`: AIっぽい文章パターンをチェックするスクリプト
  - `textlint-fix.sh`: AIっぽい文章パターンを自動修正するスクリプト
  - `mcp-setup.sh`: MCPサーバーの初期設定スクリプト
  - `mcp-test.sh`: MCPサーバーの動作確認スクリプト

- **MCP設定** 
  - `.mcp.json`: チーム共有のMCPサーバー設定
  - `.mcp.local.json`: 個人的なMCPサーバー設定（APIキー等）

### セキュリティ設計

ファイアウォールスクリプトは以下のドメインへのアクセスのみを許可します：

- GitHub API/Web/Git
- npmレジストリ
- Anthropic API
- Sentry.io
- Statsig

## Claude Code Hooks（Slack通知）

### 設定されているHooks

1. **Stop** - タスク完了時にSlackに通知（緑色、✅）
2. **Notification** - 通知イベント時にSlackに通知（黄色、🔔）
3. **SubagentStop** - サブエージェント完了時にSlackに通知（緑色、🤖）

### Slack通知の設定

詳細は `scripts/README.md` を参照してください。

**重要**: Webhook URLは `.claude/settings.local.json` に環境変数として保存されており、Gitには含まれません。

### Slack通知スクリプトの機能

`claude-slack-notification.sh`は以下の機能を提供します：

1. **JSON入力処理** - Claude Code HooksからのJSON入力を自動的に処理
2. **詳細な通知情報** - イベントタイプ、時刻、セッションIDを表示
3. **アイドル通知のフィルタリング** - 60秒アイドル通知を自動的に無視（`SLACK_NOTIFICATION_IGNORE_IDLE=0`で無効化可能）
4. **通知のカスタマイズ** - メッセージ内容に基づいて異なるアイコンと色を使用
   - 許可要求: ⚠️ 黄色
   - アイドル: ⏳ グレー
   - その他: 🔔 黄色
5. **デバッグモード** - `SLACK_NOTIFICATION_DEBUG=1`で詳細なログを記録
6. **ログローテーション** - デバッグログが指定サイズを超えると自動的にローテーション

### 環境変数

| 変数名 | 説明 | デフォルト値 |
|--------|------|-------------|
| `SLACK_WEBHOOK_URL` | SlackのWebhook URL | 必須 |
| `SLACK_NOTIFICATION_IGNORE_IDLE` | アイドル通知を無視 | `1` (有効) |
| `SLACK_NOTIFICATION_DEBUG` | デバッグモード | `0` (無効) |
| `SLACK_NOTIFICATION_IGNORE_TASK_COMPLETION` | タスク完了通知を無視 | `0` (無効) |
| `SLACK_NOTIFICATION_MAX_LOG_SIZE` | ログファイルの最大サイズ（バイト） | `10485760` (10MB) |

## textlint AI文章検出機能

このプロジェクトには、AIが生成したような文章パターンを検出・修正する `textlint-rule-preset-ai-writing` が統合されています。

### 自動チェック機能

- Markdownファイル（`.md`）を編集・作成時に自動的にAIっぽい文章をチェック
- Claude Code Hooksと統合され、問題がある場合は警告を表示

### 手動チェック・修正

```bash
# 特定のファイルをチェック
./scripts/textlint-check.sh CLAUDE.md

# すべてのMarkdownファイルをチェック
npm run lint:md

# AIっぽい文章を自動修正
./scripts/textlint-fix.sh CLAUDE.md
# または
npm run lint:md:fix
```

### 検出される主なパターン

- 機械的な箇条書き形式（絵文字や太字の過剰使用）
- AIツール特有の定型的な表現
- 不自然な強調パターン

詳細なセットアップガイドは [docs/textlint-setup.md](docs/textlint-setup.md) を参照してください。

## Model Context Protocol (MCP) サーバー

このプロジェクトには、Claude CodeがMCPサーバーを介して様々なツールやデータソースにアクセスできるよう、MCP統合が含まれています。

### 設定済みMCPサーバー

1. **filesystem** - ファイルシステムアクセス（読み取り専用）
   - `/workspace`ディレクトリへの安全なアクセス
   - 書き込み・削除・リネーム操作は無効化

2. **git** - Gitリポジトリ操作
   - 現在のプロジェクトのGit情報へのアクセス
   - コミット履歴、ブランチ、差分の確認

3. **github** (オプション) - GitHub API統合
   - `.mcp.local.json`で設定が必要
   - Issue、PR、リポジトリ情報へのアクセス

### MCPサーバーの使用方法

```bash
# MCPサーバーの一覧表示
claude mcp list

# 新しいMCPサーバーの追加
claude mcp add

# MCPサーバーの動作確認
./scripts/mcp-test.sh
```

### カスタムMCPサーバーの追加

`.mcp.local.json`を編集して、プロジェクト固有のMCPサーバーを追加できます：

```json
{
  "mcpServers": {
    "custom-server": {
      "type": "stdio",
      "command": "node",
      "args": ["path/to/your/server.js"],
      "config": {
        // サーバー固有の設定
      }
    }
  }
}
```

詳細は [docs/mcp-setup.md](docs/mcp-setup.md) を参照してください。

## カスタムスラッシュコマンド

以下のカスタムコマンドが利用可能です：

- `/project:create-command` - 新しいカスタムコマンドを作成
- `/project:edit-command` - 既存のカスタムコマンドを編集
- `/project:git-commit` - Git commitのヘルパー
- `/project:check-ai-writing` - Markdownファイルのアイっぽい文章をチェック
- `/project:fix-ai-writing` - AIっぽい文章パターンを自動修正

## 開発コマンド

### コンテナの起動

```bash
# VS Codeで開く場合
code .
# その後、"Reopen in Container"を選択
```

### ファイアウォールの手動実行（通常は自動）

```bash
sudo /usr/local/bin/init-firewall.sh
```

### Slack通知のテスト

```bash
# 環境変数が設定されていることを確認
echo $SLACK_WEBHOOK_URL

# テスト通知を送信
/workspace/scripts/claude-slack-notification.sh Stop "テストメッセージ"
```

## 環境設定

- **Node.js**: v20
- **デフォルトシェル**: Zsh (Powerlevel10k theme)
- **インストール済みツール**:
  - git, gh (GitHub CLI)
  - fzf, delta
  - iptables/ipset (ファイアウォール用)
  - Claude Code CLI
  - curl (Slack通知用)
  - textlint, textlint-rule-preset-ai-writing (AI文章検出用)

## VSCodeフォーク拡張機能の永続化

開発コンテナを再作成しても拡張機能が保持されるよう、以下の仕組みが実装されています：

### 自動永続化ボリューム

以下のボリュームが自動的にマウントされ、拡張機能が永続化されます：

- VSCode: `vscode-extensions` ボリューム（`.vscode-server/extensions`）
- Cursor: `cursor-extensions` ボリューム（`.cursor-server/extensions`）
- Windsurf: `windsurf-extensions` ボリューム（`.windsurf-server/extensions`）

### カスタム拡張機能のインストール

1. `.devcontainer/extensions/` ディレクトリにVSIXファイルを配置
2. コンテナ起動時に自動的にインストールされます
3. VSIXファイルは `.gitignore` で除外されるため、リポジトリには含まれません

### 使用方法

```bash
# VSIXファイルを配置
cp your-extension.vsix .devcontainer/extensions/

# コンテナを再起動
# 拡張機能が自動的にインストールされます
```

## 重要な注意事項

1. ファイアウォールは自動的に設定され、許可されたドメインへのアクセスのみを許可します
2. ワークスペースは `/workspace` にマウントされます
3. 設定とbash履歴は永続化ボリュームに保存されます
4. Slack Webhook URLは環境変数として管理され、Gitリポジトリには含まれません
5. `.claude/settings.local.json` は `.gitignore` に含まれており、個人設定を安全に保存できます
6. `.mcp.local.json` も `.gitignore` に含まれており、APIキーなどの秘密情報を安全に保存できます
7. VSCodeフォークの拡張機能は専用ボリュームに永続化され、コンテナ再作成後も保持されます
8. MCPサーバーはコンテナ起動時に自動的に設定されます

## セキュリティベストプラクティス

- APIキーやWebhook URLなどの秘密情報は環境変数または `settings.local.json` で管理
- 定期的にWebhook URLをローテーション（90日ごと推奨）
- 本番環境では異なるWebhook URLを使用
