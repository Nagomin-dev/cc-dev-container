# Git Commit Helper

このコマンドは、Git commitを効率的に行うためのヘルパーです。

## 使用方法
1. 変更内容を確認します（git status, git diff）
2. 適切なファイルをステージングします
3. コミットメッセージのガイドラインに従ってコミットを作成します

## コミットメッセージのガイドライン
- 1行目: 変更の要約（50文字以内）
- 2行目: 空行
- 3行目以降: 詳細な説明（必要に応じて）

## コミットタイプ
- feat: 新機能
- fix: バグ修正
- docs: ドキュメントのみの変更
- style: コードの意味に影響しない変更（空白、フォーマット等）
- refactor: バグ修正や機能追加を伴わないコード変更
- test: テストの追加や修正
- chore: ビルドプロセスやツールの変更

## ブランチ管理
コミット前に適切なブランチで作業しているか確認し、必要に応じてブランチを切り替えます。

```bash
# 現在のブランチを確認
git branch

# 新しいブランチを作成して切り替える場合
git checkout -b <branch-name>

# 既存のブランチに切り替える場合
git checkout <branch-name>

# リモートブランチを取得して切り替える場合
git fetch origin
git checkout -b <branch-name> origin/<branch-name>
```

## 実行手順
```bash
# 1. ブランチの確認と切り替え（必要に応じて）
git branch
# 必要なら: git checkout -b feature/new-feature

# 2. 現在の状態を確認
git status

# 3. 変更内容を確認
git diff

# 4. ファイルをステージング
git add <file-path>
# または全ての変更をステージング
git add .

# 5. コミット作成
git commit -m "type: 変更の要約"

# 6. リモートにプッシュ（必要に応じて）
git push origin <branch-name>
```

準備ができたら、上記の手順に従ってGitコミットを実行します。