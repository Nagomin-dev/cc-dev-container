---
description: "新しいカスタムスラッシュコマンドを作成します"
allowed-tools: ["Write", "MultiEdit", "Bash", "Read"]
---

# 新しいカスタムスラッシュコマンドを作成

引数: $ARGUMENTS

## 処理内容

このコマンドは新しいカスタムスラッシュコマンドを作成します。

### 引数の解析
- 第1引数: コマンド名（必須）
- `--user`: ユーザーレベルのコマンドとして作成（オプション）
- `--tools`: 許可するツールをカンマ区切りで指定（オプション）
- `--description`: コマンドの説明（オプション）

### 実行手順

1. 引数から情報を抽出
2. コマンド名の検証（英数字とハイフンのみ許可）
3. 保存先ディレクトリの決定と作成
   - `--user` フラグあり: `~/.claude/commands/`
   - フラグなし: `.claude/commands/`
4. コマンドファイルの作成
5. ユーザーにコマンド内容の入力を促す

### 例
- `/create-command test-command` - プロジェクトレベルのコマンドを作成
- `/create-command test-command --user` - ユーザーレベルのコマンドを作成
- `/create-command analyze --tools "Read,Grep" --description "コードを分析します"`

まず引数を解析し、その後ユーザーにコマンドの内容を尋ねてファイルを作成してください。