# Claude Code Dev Container with Slack Notifications

このプロジェクトは、Claude Code用のDev Container環境とSlack通知機能を提供します。

## 🚀 クイックスタート

1. VS Codeでプロジェクトを開く
2. "Reopen in Container"を選択
3. Slack Webhook URLを設定（詳細は[scripts/README.md](scripts/README.md)を参照）

## 📁 プロジェクト構造

```plaintext
/workspace/
├── .claude/                  # Claude Code設定
│   ├── settings.json         # チーム共有設定（Gitにコミット）
│   └── settings.local.json   # 個人設定（Gitで無視）
├── .devcontainer/            # Dev Container設定
│   ├── devcontainer.json     # コンテナ設定
│   ├── Dockerfile            # 開発環境定義
│   └── init-firewall.sh      # セキュリティ設定
├── scripts/                  # スクリプトとドキュメント
│   ├── claude-slack-notification.sh  # Slack通知スクリプト
│   └── README.md             # Slack通知セットアップガイド
├── .gitignore                # Git除外設定
├── CLAUDE.md                 # Claude Code用ガイダンス
└── README.md                 # このファイル
```

## 🔔 Slack通知機能

Claude Codeの以下のイベントでSlackに通知が送信されます：

- **Stop**: タスク完了時（緑色、✅）
- **Notification**: 通知イベント時（黄色、🔔）
- **SubagentStop**: サブエージェント完了時（緑色、🤖）

## 🔐 セキュリティ

- Webhook URLは環境変数として管理
- `.claude/settings.local.json`は`.gitignore`で除外
- Dev Containerのファイアウォールで通信を制限

## 📚 ドキュメント

- [CLAUDE.md](CLAUDE.md) - Claude Code用の詳細ガイダンス
- [scripts/README.md](scripts/README.md) - Slack通知のセットアップ手順

## 🛠️ 開発環境

- **OS**: Debian (Linux)
- **Node.js**: v20
- **Shell**: Zsh with Powerlevel10k
- **Claude Code**: インストール済み

## 📝 ライセンス

このプロジェクトの設定ファイルは自由に使用・改変できます。
