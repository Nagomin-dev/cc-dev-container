# Slack App設定ガイド（GitHub Actions連携用）

このガイドでは、GitHub ActionsからSlackに通知を送信するためのSlack Appの設定方法を詳しく説明します。

## 概要

Slack Webhook URLの制限を回避し、複数チャンネルへの動的な通知を実現するために、Slack Appを使用したBot Token方式を推奨します。

### Webhook URL vs Bot Tokenの比較

| 機能 | Webhook URL | Bot Token |
|------|-------------|-----------|
| 送信先チャンネル数 | 1つのみ | 複数可能 |
| チャンネルの動的指定 | 不可 | 可能 |
| プライベートチャンネル | 設定時に指定したチャンネルのみ | 招待されたチャンネル全て |
| セットアップの簡易さ | 簡単 | やや複雑 |
| 権限管理 | 固定 | 柔軟に設定可能 |

## Slack App作成手順

### 1. Slack Appの作成

1. [api.slack.com/apps](https://api.slack.com/apps) にアクセス
2. 右上の「Create New App」をクリック
3. 「From scratch」を選択
4. アプリ情報を入力：
   - **App Name**: `GitHub Actions Bot` （任意の名前）
   - **Pick a workspace**: 通知を送信したいワークスペースを選択
5. 「Create App」をクリック

### 2. Bot Userの設定

1. 左側メニューから「App Home」を選択
2. 「Your App's Presence in Slack」セクションで以下を設定：
   - **Always Show My Bot as Online**: オン（推奨）
3. 「Bot User」セクションがない場合は、「Review Scopes to Add」をクリック

### 3. OAuth & Permissionsの設定

1. 左側メニューから「OAuth & Permissions」を選択
2. 「Scopes」セクションまでスクロール
3. 「Bot Token Scopes」で「Add an OAuth Scope」をクリック
4. 以下のスコープを追加：
   - `chat:write` - 基本的なメッセージ送信権限
   - `chat:write.public` - パブリックチャンネルへの送信権限（ボットが参加していないチャンネルでも送信可能）
   - `chat:write.customize` - ユーザー名とアイコンのカスタマイズ（オプション）

### 4. アプリのインストール

1. ページ上部の「Install to Workspace」をクリック
2. 権限の確認画面で内容を確認
3. 「許可する」をクリック
4. インストール完了後、「Bot User OAuth Token」が表示される
5. `xoxb-`で始まるトークンをコピー（後で使用）

### 5. Bot Tokenの保存

#### GitHub Secretsへの登録

1. GitHubリポジトリにアクセス
2. Settings → Secrets and variables → Actions
3. 「New repository secret」をクリック
4. 以下を入力：
   - **Name**: `SLACK_BOT_TOKEN`
   - **Secret**: コピーしたBot Token（xoxb-で始まる文字列）
5. 「Add secret」をクリック

## チャンネルIDの確認方法

Bot Token方式では、チャンネル名ではなくチャンネルIDを使用する必要があります。

### デスクトップアプリまたはWebアプリでの確認

1. Slackでチャンネルを開く
2. チャンネル名を右クリック
3. 「チャンネル詳細を表示」または「View channel details」を選択
4. ポップアップの最下部にある「チャンネルID」をコピー

### モバイルアプリでの確認

1. チャンネルを開く
2. 上部のチャンネル名をタップ
3. 「設定」または歯車アイコンをタップ
4. 下にスクロールして「チャンネルID」を確認

### APIでの確認

```bash
# Slack APIを使用してチャンネル一覧を取得
curl -H "Authorization: Bearer <YOUR_SLACK_BOT_TOKEN>" \
  https://slack.com/api/conversations.list?types=public_channel,private_channel
```

## GitHub Variablesの設定

チャンネルIDはハードコードせず、GitHub Variablesで管理することを推奨します。

### Repository Variablesの設定

1. GitHubリポジトリ → Settings → Secrets and variables → Actions
2. 「Variables」タブを選択
3. 「New repository variable」をクリック
4. 以下のような変数を追加：

```
SLACK_CHANNEL_ID=C1234567890
SLACK_CHANNEL_GITHUB_NOTIFICATIONS=C1234567890
SLACK_CHANNEL_PRODUCTION_ALERTS=C0987654321
SLACK_CHANNEL_URGENT_NOTIFICATIONS=C1122334455
SLACK_CHANNEL_SECURITY_ALERTS=C5566778899
```

### Organization Variablesの設定（組織全体で使用する場合）

1. GitHub Organization → Settings → Secrets and variables → Actions
2. 同様の手順で変数を追加

## プライベートチャンネルへの送信

プライベートチャンネルに送信する場合は、以下の手順が必要です：

1. 対象のプライベートチャンネルにアプリを招待
   - チャンネルで `/invite @GitHub Actions Bot` を実行
   - またはチャンネル設定から「インテグレーション」→「アプリを追加」

2. チャンネルIDを確認して使用

## トラブルシューティング

### 「channel_not_found」エラー

- チャンネルIDが正しいか確認（チャンネル名ではなくID）
- プライベートチャンネルの場合、ボットが招待されているか確認
- `chat:write.public`スコープが付与されているか確認

### 「not_authed」エラー

- Bot Tokenが正しく設定されているか確認
- トークンが`xoxb-`で始まっているか確認
- GitHub Secretsの名前が正しいか確認

### 「missing_scope」エラー

- 必要なスコープが付与されているか確認
- アプリを再インストールして権限を更新

## セキュリティのベストプラクティス

1. **Bot Tokenの管理**
   - 絶対にコードにハードコードしない
   - GitHub Secretsで安全に管理
   - 定期的にトークンをローテーション（90日ごと推奨）

2. **最小権限の原則**
   - 必要最小限のスコープのみを付与
   - 不要になったスコープは削除

3. **チャンネルアクセスの制限**
   - センシティブな情報を扱うチャンネルへのアクセスは慎重に

4. **監査ログの確認**
   - Slack管理画面で定期的にアプリのアクティビティを確認

## 参考リンク

- [Slack API Documentation](https://api.slack.com/)
- [GitHub Actions: Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [slackapi/slack-github-action](https://github.com/slackapi/slack-github-action)
