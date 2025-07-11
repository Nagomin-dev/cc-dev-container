# Claude Code Slack通知セットアップガイド

## 概要

Claude CodeのHooks機能を使用して、タスク完了時やイベント発生時にSlackに通知を送信します。Dev Container環境でも問題なく動作します。

## セットアップ手順

### 1. Slack Webhookの作成

1. Slackワークスペースにログイン
2. <https://api.slack.com/apps> にアクセス
3. 「Create New App」をクリック
4. 「From scratch」を選択
5. アプリ名を入力（例：Claude Code Notifications）
6. ワークスペースを選択して「Create App」

### 2. Incoming Webhooksの有効化

1. 作成したアプリの設定画面で「Incoming Webhooks」をクリック
2. 「Activate Incoming Webhooks」をオンにする
3. 「Add New Webhook to Workspace」をクリック
4. 通知を送信したいチャンネルを選択
5. 生成されたWebhook URLをコピー

### 3. 環境変数の設定

#### 方法A: シェルの設定ファイルに追加（推奨）

```bash
# ~/.bashrc または ~/.zshrc に追加
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

設定後、シェルを再起動または以下を実行：

```bash
source ~/.bashrc  # または source ~/.zshrc
```

#### 方法B: Dev Container設定に追加

`.devcontainer/devcontainer.json`に以下を追加：

```json
"remoteEnv": {
  "SLACK_WEBHOOK_URL": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
}
```

### 4. 動作確認

```bash
# 環境変数が設定されているか確認
echo $SLACK_WEBHOOK_URL

# テスト通知を送信
/workspace/claude-slack-notification.sh Stop "テスト通知です"
```

## 通知の種類

### 1. Stopイベント（タスク完了）✅

- **発生タイミング**: メインエージェントの応答が終了したとき
- **Slack表示**: 緑色のアタッチメント、チェックマーク付き

### 2. Notificationイベント（通知）🔔

- **発生タイミング**:
  - ツール使用の許可要求時
  - 60秒以上のアイドル状態時
- **Slack表示**: 黄色のアタッチメント、ベルアイコン付き

### 3. SubagentStopイベント（サブエージェント完了）🤖

- **発生タイミング**: サブエージェントが終了したとき
- **Slack表示**: 緑色のアタッチメント、ロボット顔アイコン付き

## カスタマイズ

### アイコンの変更

`claude-slack-notification.sh`の`icon_emoji`を編集：

```bash
"icon_emoji": ":robot_face:"  # お好みの絵文字に変更
```

### 通知先チャンネルの動的変更

スクリプトに以下を追加：

```bash
"channel": "#general"  # 特定のチャンネルを指定
```

### メンション追加

メッセージに`<@USER_ID>`を含める：

```bash
DEFAULT_MSG="<@U12345678> Claude Codeがタスクを完了しました"
```

## トラブルシューティング

### 通知が届かない場合

1. **環境変数を確認**：

   ```bash
   echo $SLACK_WEBHOOK_URL
   ```

2. **手動でWebhookをテスト**：

   ```bash
   curl -X POST -H 'Content-type: application/json' \
     --data '{"text":"Test message"}' \
     $SLACK_WEBHOOK_URL
   ```

3. **スクリプトの実行権限を確認**：

   ```bash
   ls -la /workspace/claude-slack-notification.sh
   # 実行権限がない場合：
   chmod +x /workspace/claude-slack-notification.sh
   ```

4. **ログを確認**：
   設定ファイルで`suppressOutput`を`false`に変更して出力を確認

## セキュリティに関する注意

- Webhook URLは秘密情報です。Gitリポジトリにコミットしないでください
- 環境変数として管理し、必要な人のみアクセスできるようにしてください
- Webhook URLが漏洩した場合は、Slackアプリ設定から再生成してください

## ファイル構成

- `/workspace/claude-slack-notification.sh` - Slack通知スクリプト
- `/workspace/.claude/settings.json` - Claude Code Hooks設定
