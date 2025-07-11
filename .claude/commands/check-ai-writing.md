# Check AI Writing

指定されたファイルまたはディレクトリのMarkdownファイルに対して、AIっぽい文章パターンをチェックします。

## 使用方法

1. 特定のファイルをチェックする場合:
   - ファイルパスを指定してください（例: `CLAUDE.md`、`docs/README.md`）

2. ディレクトリ全体をチェックする場合:
   - ディレクトリパスを指定してください（例: `docs/`）
   - 何も指定しない場合は、プロジェクト全体のMarkdownファイルをチェックします

## アシスタントへの指示

1. ユーザーが指定したファイルまたはディレクトリに対して `/workspace/scripts/textlint-check.sh` を実行してください
2. 結果を分かりやすく表示してください
3. AIっぽい文章パターンが検出された場合は、修正方法を提案してください
4. 必要に応じて `/project:fix-ai-writing` コマンドの使用を提案してください

## 実行例

```bash
# 特定のファイルをチェック
/workspace/scripts/textlint-check.sh CLAUDE.md

# すべてのMarkdownファイルをチェック
/workspace/scripts/textlint-check.sh
```