# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

このリポジトリは、Claude Code用のDev Container環境を提供します。VS CodeのRemote - Containers拡張機能を使用して、一貫した開発環境を構築できます。Slack通知機能を含む、Claude Code Hooksが設定されています。

## アーキテクチャと構造

### ディレクトリ構造

```
/workspace/
├── .claude/
│   ├── commands/             # カスタムスラッシュコマンド
│   │   ├── create-command.md # /project:create-command
│   │   ├── edit-command.md   # /project:edit-command
│   │   └── git-commit.md     # /project:git-commit
│   ├── settings.json         # チーム共有のClaude Code設定
│   └── settings.local.json   # 個人設定（Gitで無視）
├── .devcontainer/
│   ├── devcontainer.json     # VS Code用のコンテナ設定
│   ├── Dockerfile            # Node.js 20ベースの開発環境
│   └── init-firewall.sh      # セキュリティのためのファイアウォール設定
├── scripts/
│   └── claude-slack-notification.sh  # Slack通知スクリプト
├── .gitignore                # Git除外設定
├── CLAUDE.md                 # このファイル
└── claude-slack-setup.md     # Slack通知セットアップガイド
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

## カスタムスラッシュコマンド

以下のカスタムコマンドが利用可能です：

- `/project:create-command` - 新しいカスタムコマンドを作成
- `/project:edit-command` - 既存のカスタムコマンドを編集
- `/project:git-commit` - Git commitのヘルパー

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

## 重要な注意事項

1. ファイアウォールは自動的に設定され、許可されたドメインへのアクセスのみを許可します
2. ワークスペースは `/workspace` にマウントされます
3. 設定とbash履歴は永続化ボリュームに保存されます
4. Slack Webhook URLは環境変数として管理され、Gitリポジトリには含まれません
5. `.claude/settings.local.json` は `.gitignore` に含まれており、個人設定を安全に保存できます

## セキュリティベストプラクティス

- APIキーやWebhook URLなどの秘密情報は環境変数または `settings.local.json` で管理
- 定期的にWebhook URLをローテーション（90日ごと推奨）
- 本番環境では異なるWebhook URLを使用