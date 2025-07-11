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
│   ├── init-firewall.sh      # セキュリティのためのファイアウォール設定
│   ├── setup-branch-protection.sh  # ブランチ保護の自動設定
│   └── branch-protection-rules.json # ブランチ保護ルールの設定
├── scripts/
│   └── claude-slack-notification.sh  # Slack通知スクリプト
├── .gitignore                # Git除外設定
├── .pre-commit-config.yaml   # pre-commitフック設定
├── CLAUDE.md                 # このファイル
└── claude-slack-setup.md     # Slack通知セットアップガイド
```

### 主要コンポーネント

- **Dev Container設定** (.devcontainer/)
  - `devcontainer.json`: VS Code用のコンテナ設定（GitHub CLI機能を含む）
  - `Dockerfile`: Node.js 20ベースの開発環境（pre-commit含む）
  - `init-firewall.sh`: セキュリティのためのファイアウォール設定スクリプト
  - `setup-branch-protection.sh`: GitHubとローカルのブランチ保護を自動設定
  - `branch-protection-rules.json`: カスタマイズ可能なブランチ保護ルール

- **Claude Code設定** (.claude/)
  - `settings.json`: チーム共有のhooks設定
  - `settings.local.json`: 個人的な設定（Webhook URLなど）

- **スクリプト** (scripts/)
  - `claude-slack-notification.sh`: Slack通知を送信するスクリプト
  - `setup-branch-protection.sh`: ブランチ保護を設定するスクリプト

- **ブランチ保護設定**
  - `.pre-commit-config.yaml`: ローカルでのブランチ保護用pre-commitフック
  - `branch-protection-rules.json`: GitHub API用のブランチ保護ルール設定

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
  - Python 3, pip (pre-commit用)
  - pre-commit (ローカルGitフック管理)

## 重要な注意事項

1. ファイアウォールは自動的に設定され、許可されたドメインへのアクセスのみを許可します
2. ワークスペースは `/workspace` にマウントされます
3. 設定とbash履歴は永続化ボリュームに保存されます
4. Slack Webhook URLは環境変数として管理され、Gitリポジトリには含まれません
5. `.claude/settings.local.json` は `.gitignore` に含まれており、個人設定を安全に保存できます

## ブランチ保護

### 概要

このDev Container環境は、リポジトリの初期化時に自動的にブランチ保護を設定します：

1. **GitHubブランチ保護** (リモート)
   - プルリクエストレビューの必須化
   - ステータスチェックの必須化
   - 強制プッシュとブランチ削除の防止
   - 会話の解決を必須化

2. **ローカルGitフック** (pre-commit)
   - main/master/develop/stagingブランチへの直接コミット防止
   - コード品質チェック（trailing whitespace、大きなファイルの検出など）

### 保護されるブランチ

- `main` / `master` (デフォルトブランチ)
- `develop` (開発ブランチ)
- `staging` (ステージング環境用)

### セットアップ

ブランチ保護は `postCreateCommand` で自動的に実行されます。手動で実行する場合：

```bash
/workspace/.devcontainer/setup-branch-protection.sh
```

### GitHub認証

リモートブランチ保護を有効にするには、GitHub CLIで認証が必要です：

```bash
gh auth login
```

### カスタマイズ

ブランチ保護ルールをカスタマイズするには、`.devcontainer/branch-protection-rules.json` を編集してください：

```json
{
  "branches": ["main", "master", "develop", "staging"],
  "required_approving_review_count": 1,
  "dismiss_stale_reviews": true,
  // その他のオプション...
}
```
   - コード品質チェック（空白、ファイルサイズなど）
   - カスタムpre-pushフックで保護ブランチへのプッシュ警告

### 設定方法

#### GitHub認証

GitHubのブランチ保護を有効にするには：

```bash
# 方法1: GitHub CLIで認証
gh auth login

# 方法2: 環境変数でトークンを設定
export GITHUB_TOKEN=your_personal_access_token
```

#### カスタマイズ

ブランチ保護ルールをカスタマイズするには、`.devcontainer/branch-protection-rules.json`を編集します。

#### 手動実行

```bash
# ブランチ保護の再設定
/workspace/.devcontainer/setup-branch-protection.sh

# ローカルフックのみ再設定
pre-commit install
```

### 緊急時の回避方法

ローカルフックを一時的に無効化：
```bash
git commit --no-verify
git push --no-verify
```

**注意**: これらのオプションは緊急時のみ使用し、通常はプルリクエストを使用してください。

## セキュリティベストプラクティス

- APIキーやWebhook URLなどの秘密情報は環境変数または `settings.local.json` で管理
- 定期的にWebhook URLをローテーション（90日ごと推奨）
- 本番環境では異なるWebhook URLを使用
- GitHubトークンは最小限の権限（repo権限）で作成
- ブランチ保護ルールは定期的に見直し、チームの要件に合わせて更新