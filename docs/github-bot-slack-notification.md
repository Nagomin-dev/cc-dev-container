# GitHub Bot Comment Slack通知ガイド

## 概要

このドキュメントでは、CodeRabbitやClaude Code ActionなどのボットがGitHub上でコメントした際に、自動的にSlackに通知を送信する仕組みについて説明します。

## 利用可能なワークフロー

### 1. 基本版 (`bot-comment-notify.yml`)

シンプルな実装で、CodeRabbitとClaude Code Actionのコメントを検知してSlackに通知します。

**特徴：**

- CodeRabbitとGitHub Actionsボットのコメントを自動検知
- ボットタイプに応じたアイコンと色分け
- コメントの最初の500文字をプレビュー表示

### 2. 高度版 (`bot-comment-notify-advanced.yml`)

より柔軟な設定が可能な実装で、キーワードフィルタリングや重要度判定などの機能を含みます。

**特徴：**

- 環境変数による通知設定のカスタマイズ
- キーワードベースのフィルタリング
- コメント内容に基づく重要度判定
- チャンネル自動振り分け
- メンション機能（重要なコメントの場合）

## セットアップ手順

### ⚠️ 重要: 必須設定について

**このワークフローを動作させるには、以下の設定が必須です：**

1. **Slack認証情報の設定** (Bot TokenまたはWebhook URL)
2. **チャンネルIDの設定** (Bot Token方式の場合)

設定が不完全な場合、ワークフローは明確なエラーメッセージと共に失敗します。

### 1. Slack Bot Tokenの設定（推奨）

**重要**: Slack Webhook URLは単一チャンネルにしか送信できません。複数チャンネルへの通知が必要な場合は、Bot Token方式を使用してください。

#### Bot Token方式（複数チャンネル対応）

1. **Slack Appの作成**
   - [api.slack.com/apps](https://api.slack.com/apps) にアクセス
   - "Create New App" → "From scratch"を選択
   - アプリ名とワークスペースを設定

2. **権限の設定**
   - "OAuth & Permissions"ページへ移動
   - "Scopes" → "Bot Token Scopes"で以下を追加：
     - `chat:write` - メッセージ送信権限
     - `chat:write.public` - パブリックチャンネルへの送信権限

3. **アプリのインストール**
   - "Install to Workspace"をクリック
   - 権限を確認して承認

4. **Bot Tokenの取得**
   - "OAuth & Permissions"ページの"Bot User OAuth Token"をコピー
   - `xoxb-`で始まるトークン

5. **GitHub Secretsへの登録**
   ```bash
   # GitHubリポジトリ > Settings > Secrets and variables > Actions
   # "New repository secret"から SLACK_BOT_TOKEN を追加
   ```

6. **チャンネルIDの確認**
   - Slackでチャンネルを右クリック → "View channel details"
   - 最下部の"Channel ID"をコピー（例: C1234567890）

#### Webhook URL方式（単一チャンネルのみ）

既存のWebhook URLを使用する場合：

```bash
# GitHubリポジトリ > Settings > Secrets and variables > Actions
# "New repository secret"から SLACK_WEBHOOK_URL を追加
```

**注意**: Webhook URL方式では、チャンネル振り分け機能は動作しません。

### 2. ワークフローファイルの選択

用途に応じて、以下のいずれかのワークフローを使用します。

- 基本的な通知のみ必要な場合 - `bot-comment-notify.yml`
- 高度なフィルタリングが必要な場合 - `bot-comment-notify-advanced.yml`

### 3. ワークフローの設定

#### 基本版（bot-comment-notify.yml）

**必須設定：**

Bot Token方式の場合、GitHub Variablesで`SLACK_CHANNEL_ID`を設定：

```bash
# GitHubリポジトリ > Settings > Secrets and variables > Actions > Variables
# 【必須】通知先のチャンネルID（例: C1234567890）
SLACK_CHANNEL_ID=C1234567890
```

**設定チェック：**
- ワークフロー実行時に設定が正しいかを自動チェック
- 設定が不完全な場合は詳細なエラーメッセージを表示

#### 高度版（bot-comment-notify-advanced.yml）

**必須設定：**

```bash
# GitHubリポジトリ > Settings > Secrets and variables > Actions > Variables
# 【必須】デフォルト通知チャンネル
SLACK_CHANNEL_GITHUB_NOTIFICATIONS=C1234567890
```

**任意設定（チャンネル振り分け用）：**

```bash
# 【任意】mainブランチPR用チャンネル
SLACK_CHANNEL_PRODUCTION_ALERTS=C0987654321

# 【任意】urgentラベル用チャンネル  
SLACK_CHANNEL_URGENT_NOTIFICATIONS=C1122334455

# 【任意】securityラベル用チャンネル
SLACK_CHANNEL_SECURITY_ALERTS=C5566778899
```

**設定チェック：**
- 必須設定が不完全な場合は詳細なエラーメッセージを表示
- 任意設定が未設定の場合はデフォルトチャンネルを使用（警告表示）
- GitHub API呼び出し失敗時の適切なフォールバック処理

### 4. ワークフローの有効化

選択したワークフローファイルを `.github/workflows/` ディレクトリに配置すると、自動的に有効になります。

## 基本版の使い方

### 動作条件

- PRまたはIssueへのコメント作成時
- コメント投稿者が以下のいずれか：
  - CodeRabbit（`coderabbitai`を含むユーザー名）
  - GitHub Actions bot（Claude Code Action含む）

### 通知内容

- ボットの種類（CodeRabbit/Claude Code Action）
- リポジトリ名
- PR/Issue番号とタイトル
- コメントのプレビュー（最初の500文字）
- コメントへの直接リンク

## 高度版の使い方

### 環境変数による設定

ワークフローファイル内の`env`セクションで以下の設定が可能：

```yaml
env:
  # 通知するキーワード（カンマ区切り）
  NOTIFY_KEYWORDS: "review,approved,changes requested,vulnerability,error,warning,bug,security"
  
  # 無視するキーワード（カンマ区切り）
  IGNORE_KEYWORDS: "WIP,draft,test"
  
  # ボット別の通知設定
  NOTIFY_CODERABBIT: "true"
  NOTIFY_CLAUDE: "true"
  NOTIFY_OTHER_BOTS: "false"
```

### 重要度判定

コメント内容に基づいて自動的に重要度を判定：

- 高重要度 - error, failed, bug, vulnerability, security
- 成功 - approved, lgtm, success, passed
- 警告 - warning, suggestion, consider
- 通常 - その他

高重要度のコメントには`@channel`メンションが自動的に追加されます。

### チャンネル振り分け（Bot Token方式のみ）

Bot Token方式を使用している場合、以下の条件でSlackチャンネルが自動選択されます。

#### GitHub Variablesの設定

チャンネルIDはGitHub Repository VariablesまたはOrganization Variablesで管理することを推奨します：

**設定手順：**
1. GitHub リポジトリの Settings > Secrets and variables > Actions に移動
2. Variables タブで "New repository variable" をクリック
3. 以下の変数を設定：

```bash
# 【必須】デフォルト通知チャンネル
SLACK_CHANNEL_GITHUB_NOTIFICATIONS=C1234567890

# 【任意】特定条件用チャンネル（未設定時はデフォルトチャンネルを使用）
SLACK_CHANNEL_PRODUCTION_ALERTS=C0987654321         # mainブランチPR用
SLACK_CHANNEL_URGENT_NOTIFICATIONS=C1122334455      # urgentラベル用  
SLACK_CHANNEL_SECURITY_ALERTS=C5566778899           # securityラベル用
```

**重要：** フォールバック用のダミーチャンネルIDは削除されました。必須設定が未設定の場合、ワークフローは明確なエラーメッセージと共に失敗します。

#### 振り分けルール

- mainブランチへのPR: `SLACK_CHANNEL_PRODUCTION_ALERTS`
- `urgent`ラベル付き: `SLACK_CHANNEL_URGENT_NOTIFICATIONS`
- `security`ラベル付き: `SLACK_CHANNEL_SECURITY_ALERTS`
- デフォルト: `SLACK_CHANNEL_GITHUB_NOTIFICATIONS`

**注意**: Webhook URL方式では、この機能は利用できません。

## ボット判定ロジック

### CodeRabbitの判定

ユーザー名に`coderabbit`が含まれる場合、CodeRabbitとして判定されます。

### Claude Code Actionの判定

1. ユーザー名が`github-actions[bot]`
2. かつ、コメント内容に以下のいずれかが含まれる：
   - Claude
   - Anthropic
   - claude-code-action
   - Claude Code

## カスタマイズ

### 通知フォーマットの変更

Slackペイロードの`blocks`セクションを編集することで、通知の見た目をカスタマイズできます。

### 新しいボットの追加

`Determine bot type`ステップに新しい条件を追加：

```yaml
elif [[ "${{ github.event.comment.user.login }}" =~ "your-bot-name" ]]; then
  echo "bot_name=Your Bot Name" >> $GITHUB_OUTPUT
  echo "bot_icon=🤖" >> $GITHUB_OUTPUT
  echo "bot_color=#YOUR_COLOR" >> $GITHUB_OUTPUT
```

### フィルタリング条件の追加

`Check if should notify`ステップにカスタム条件を追加できます。

## トラブルシューティング

### 通知が届かない場合

#### 1. **設定エラーの確認**

新しいワークフローでは設定不完全時に詳細なエラーメッセージが表示されます：

```
❌ エラー: SLACK_CHANNEL_ID が設定されていません
📋 セットアップ手順:
1. GitHub リポジトリの Settings > Secrets and variables > Actions に移動
2. Variables タブで 'New repository variable' をクリック
3. Name: SLACK_CHANNEL_ID, Value: 実際のSlackチャンネルID を入力
4. 詳細は docs/github-bot-slack-notification.md を参照
```

**対処法：**
- GitHub Actions の実行ログでエラーメッセージを確認
- 指示に従って必須設定を追加

#### 2. **GitHub Secretsの確認**

```bash
# ワークフローログでSecretが設定されているか確認
# Settings > Actions > 該当のワークフロー実行 > ログを確認
```

#### 3. **ボット判定の確認**
- コメント投稿者のユーザー名を確認
- Claude Code Actionの場合、コメント内容にキーワードが含まれているか確認

#### 4. **Bot Token方式の場合**
- Bot Tokenが正しく設定されているか確認（`xoxb-`で始まる）
- Slackアプリがワークスペースにインストールされているか確認
- 必要な権限（chat:write, chat:write.public）が付与されているか確認
- チャンネルIDが正しいか確認（チャンネル名ではなくID）

#### 5. **Webhook URL方式の場合**

```bash
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test from GitHub Actions"}' \
  YOUR_WEBHOOK_URL
```

### チャンネル振り分けが機能しない場合

- **Bot Token方式を使用しているか確認** - Webhook URL方式では機能しません
- **GitHub Variablesが正しく設定されているか確認**
- **チャンネルIDの形式を確認**（C1234567890のような形式）

### GitHub API関連のエラー

高度版ワークフローでGitHub API呼び出しが失敗する場合：

```
❌ GitHub API呼び出しに失敗しました
⚠️  デフォルトチャンネルを使用します
```

または

```
❌ GitHub API エラー (HTTP 403)
⚠️  デフォルトチャンネルを使用します
```

**原因と対処法：**
- **レート制限**: GitHub API のレート制限に達した場合（通常は自動回復）
- **権限不足**: ワークフローの`GITHUB_TOKEN`権限が不足
- **一時的な障害**: GitHub側の一時的な問題（自動的にフォールバック）

**対処不要：** エラーが発生してもデフォルトチャンネルで通知は送信されます。

### 特定のコメントだけ通知したい場合

高度版を使用し、`NOTIFY_KEYWORDS`環境変数に必要なキーワードのみを設定します。

### 通知が多すぎる場合

- `IGNORE_KEYWORDS`に除外したいキーワードを追加
- 特定のボットの通知を無効化（例: `NOTIFY_OTHER_BOTS: "false"`）

## セキュリティ考慮事項

- Webhook URLは必ずGitHub Secretsで管理
- ワークフローファイルにWebhook URLを直接記載しない
- 定期的にWebhook URLをローテーション（推奨: 90日ごと）

## 関連ファイル

- `.github/workflows/bot-comment-notify.yml` - 基本的な通知ワークフロー
- `.github/workflows/bot-comment-notify-advanced.yml` - 高度な通知ワークフロー
- `scripts/claude-slack-notification.sh` - ローカルClaude Code用のSlack通知スクリプト
- `docs/slack-app-setup.md` - Slack App設定の詳細ガイド
