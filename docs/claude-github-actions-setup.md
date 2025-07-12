# Claude GitHub Actions セットアップガイド

このガイドでは、Claude Code GitHub Actionsを設定する手順を説明します。

## 前提条件

- GitHubリポジトリの管理者権限
- Claude Codeアカウント

## セットアップ手順

### 1. CLAUDE_CODE_OAUTH_TOKENの取得

1. [Claude Code](https://claude.ai/code)にログイン
2. GitHub Appをインストール（未インストールの場合）
   - Claude Codeの設定画面でGitHub統合を有効化
   - 必要な権限を承認

3. OAuth Tokenの取得
   - Claude Codeの設定画面から「GitHub Actions」セクションにアクセス
   - 「Generate Token」をクリック
   - 生成されたトークンをコピー（再表示されないため安全に保管）

### 2. GitHub Secretsへの設定

1. GitHubリポジトリにアクセス
2. Settings → Secrets and variables → Actions を選択
3. 「New repository secret」をクリック
4. 以下の情報を入力：
   - **Name**: `CLAUDE_CODE_OAUTH_TOKEN`
   - **Value**: 取得したOAuth Token
5. 「Add secret」をクリック

### 3. ワークフローの有効化

1. `.github/workflows/`ディレクトリに以下のファイルが存在することを確認：
   - `claude-code-review.yml` - PR自動レビュー用
   - `claude.yml` - @claudeメンション応答用

2. プルリクエストを作成して動作確認

## 動作確認

### PR自動レビューの確認

1. 新しいプルリクエストを作成
2. 数分以内に日本語でのレビューコメントが投稿される

### @claudeメンションの確認

1. PRまたはIssueでコメントを作成
2. コメント内に`@claude`を含める
3. 日本語での応答が返ってくる

## トラブルシューティング

### エラー: "Resource not accessible by integration"

- **原因**: トークンの権限不足
- **解決策**: Claude Codeで新しいトークンを生成し、必要な権限が付与されていることを確認

### エラー: "Bad credentials"

- **原因**: トークンが無効または期限切れ
- **解決策**: 新しいトークンを生成してSecretを更新

### レビューコメントが投稿されない

- **原因**: ワークフローの権限設定
- **確認事項**:

  ```yaml
  permissions:
    pull-requests: write
    issues: write
  ```

## セキュリティ上の注意

- OAuth Tokenは決して公開リポジトリにコミットしない
- 定期的にトークンをローテーション（90日ごと推奨）
- 不要になったトークンは必ず無効化する

## 関連ドキュメント

- [Claude Code公式ドキュメント](https://docs.anthropic.com/en/docs/claude-code)
- [GitHub Actions セキュリティガイド](https://docs.github.com/en/actions/security-guides)
