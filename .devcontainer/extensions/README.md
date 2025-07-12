# VSCode Extensions Directory

このディレクトリは、開発コンテナで使用するVSCode/Cursor/Windsurf等の拡張機能のVSIXファイルを配置するためのものです。

## 使用方法

1. 永続化したい拡張機能のVSIXファイルをこのディレクトリに配置します
2. コンテナの起動時に自動的にインストールされます

## VSIXファイルの入手方法

### VSCode Marketplace から
```bash
# 例: ESLint拡張機能
curl -L -o dbaeumer.vscode-eslint-2.4.4.vsix \
  https://marketplace.visualstudio.com/_apis/public/gallery/publishers/dbaeumer/vsextensions/vscode-eslint/2.4.4/vspackage
```

### Cursor/Windsurf の拡張機能
各エディタの拡張機能マーケットプレイスから直接ダウンロードするか、
インストール済みの拡張機能ディレクトリからコピーしてください。

## 注意事項

- VSIXファイルは`.gitignore`に追加することを推奨します（ファイルサイズが大きいため）
- ライセンスに注意してVSIXファイルを配布してください
- 拡張機能のバージョンアップ時は、古いVSIXファイルを削除してから新しいものを配置してください

## 拡張機能の永続化

開発コンテナには以下のボリュームマウントが設定されており、拡張機能は自動的に永続化されます：

- VSCode: `vscode-extensions` ボリューム
- Cursor: `cursor-extensions` ボリューム  
- Windsurf: `windsurf-extensions` ボリューム

これにより、コンテナを再作成しても拡張機能は保持されます。
