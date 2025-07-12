#!/bin/bash

# VSCode/Cursor/Windsurf拡張機能インストールスクリプト

EXTENSIONS_DIR="/workspace/.devcontainer/extensions"

# 拡張機能ディレクトリが存在しない場合は終了
if [ ! -d "$EXTENSIONS_DIR" ]; then
    echo "Extensions directory not found: $EXTENSIONS_DIR"
    exit 0
fi

# VSIXファイルが存在しない場合は終了
if ! ls "$EXTENSIONS_DIR"/*.vsix 1> /dev/null 2>&1; then
    echo "No VSIX files found in $EXTENSIONS_DIR"
    exit 0
fi

echo "Installing extensions from $EXTENSIONS_DIR..."

# VS Codeサーバーが利用可能か確認
if command -v code &> /dev/null; then
    echo "Installing extensions for VS Code..."
    for vsix in "$EXTENSIONS_DIR"/*.vsix; do
        if [ -f "$vsix" ]; then
            echo "  Installing: $(basename "$vsix")"
            code --install-extension "$vsix" || echo "  Failed to install: $(basename "$vsix")"
        fi
    done
fi

# Cursorサーバーが利用可能か確認
if command -v cursor &> /dev/null; then
    echo "Installing extensions for Cursor..."
    for vsix in "$EXTENSIONS_DIR"/*.vsix; do
        if [ -f "$vsix" ]; then
            echo "  Installing: $(basename "$vsix")"
            cursor --install-extension "$vsix" || echo "  Failed to install: $(basename "$vsix")"
        fi
    done
fi

# Windsurfサーバーが利用可能か確認
if command -v windsurf &> /dev/null; then
    echo "Installing extensions for Windsurf..."
    for vsix in "$EXTENSIONS_DIR"/*.vsix; do
        if [ -f "$vsix" ]; then
            echo "  Installing: $(basename "$vsix")"
            windsurf --install-extension "$vsix" || echo "  Failed to install: $(basename "$vsix")"
        fi
    done
fi

echo "Extension installation completed."
