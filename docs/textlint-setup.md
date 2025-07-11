# textlint AI文章検出機能セットアップガイド

このドキュメントでは、`textlint-rule-preset-ai-writing`を使用したAI文章検出機能について説明します。

## 概要

`textlint-rule-preset-ai-writing`は、AIツールが生成したような文章パターンを検出し、より自然な日本語表現への修正を促すtextlintルールセットです。

## セットアップ

### 1. 初期設定（すでに完了）

このプロジェクトでは、以下の設定がすでに完了しています：

- `package.json`にtextlintと関連パッケージを追加
- `.textlintrc.json`設定ファイルの作成
- Claude Code Hooksとの統合
- カスタムスラッシュコマンドの追加

### 2. 新規環境でのセットアップ

新しい環境でセットアップする場合：

```bash
# パッケージのインストール
npm install

# または、グローバルインストール
npm install -g textlint textlint-rule-preset-ai-writing
```

## 使用方法

### コマンドライン

```bash
# 単一ファイルのチェック
npx textlint README.md

# 複数ファイルのチェック
npx textlint "docs/**/*.md"

# 自動修正
npx textlint --fix README.md
```

### npm scripts

```bash
# すべてのMarkdownファイルをチェック
npm run lint:md

# 自動修正
npm run lint:md:fix
```

### カスタムスクリプト

```bash
# チェックスクリプト
./scripts/textlint-check.sh [ファイルパス]

# 自動修正スクリプト（バックアップ付き）
./scripts/textlint-fix.sh [ファイルパス]
```

### Claude Codeスラッシュコマンド

- `/project:check-ai-writing` - AIっぽい文章をチェック
- `/project:fix-ai-writing` - AIっぽい文章を自動修正

## 検出されるパターン

### 1. 機械的なリスト形式

```markdown
# 検出される例
- ✅ 完了しました
- ❌ エラーが発生しました
- **重要**: この点に注意してください

# 推奨される形式
- 完了しました
- エラーが発生しました
- この点に注意してください（重要）
```

### 2. 過剰な強調表現

```markdown
# 検出される例
**注意**: これは重要です。
**ポイント**: 以下の点を確認してください。

# 推奨される形式
これは重要な注意点です。
以下の点を確認してください。
```

### 3. AIツール特有の定型表現

textlintは、AIツールがよく使用する定型的な表現パターンを検出します。

## Claude Code Hooksとの統合

### 自動チェックの仕組み

1. **Write Hook**: 新規Markdownファイル作成時に自動チェック
2. **Edit Hook**: 既存Markdownファイル編集時に自動チェック

### フックの無効化

一時的にフックを無効化したい場合は、`.claude/settings.local.json`でオーバーライドできます：

```json
{
  "hooks": {
    "Write": [],
    "Edit": []
  }
}
```

## トラブルシューティング

### よくある問題

1. **textlintが見つからない**
   ```bash
   npm install
   ```

2. **設定ファイルが読み込まれない**
   - `.textlintrc.json`がプロジェクトルートにあることを確認
   - 設定ファイルの構文エラーをチェック

3. **自動修正が期待通りに動作しない**
   - 一部のパターンは手動修正が必要
   - バックアップから復元して手動で修正

### デバッグ

```bash
# 詳細なログを表示
npx textlint --debug README.md

# ルールの一覧を確認
npx textlint --print-config
```

## カスタマイズ

### ルールの調整

`.textlintrc.json`を編集してルールを調整できます：

```json
{
  "rules": {
    "preset-ai-writing": {
      "severity": "warning"  // error, warning, info から選択
    }
  }
}
```

### 特定のファイルを除外

`.textlintignore`ファイルを作成：

```
node_modules/
dist/
*.min.js
```

## ベストプラクティス

1. **定期的なチェック**
   - コミット前にtextlintを実行
   - CI/CDパイプラインに組み込む

2. **段階的な導入**
   - 最初は警告のみ表示
   - チームに慣れてきたらエラーに変更

3. **コンテキストを考慮**
   - すべての検出が間違いではない
   - 文脈に応じて判断

## 参考リンク

- [textlint公式ドキュメント](https://textlint.github.io/)
- [textlint-rule-preset-ai-writing](https://github.com/textlint-ja/textlint-rule-preset-ai-writing)
- [textlintルールの作成方法](https://textlint.github.io/docs/rule-author.html)