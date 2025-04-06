# デフォルトのシェルをbashに設定
SHELL := /bin/bash

# 環境変数の設定
export PORT ?= 3000
export CURRENT_ENV ?= development
export CONFIG_MESSAGE ?= "テスト用ConfigMapメッセージ"
export SECRET_KEY ?= "テスト用シークレット"

.PHONY: help install start test test-watch clean

# ヘルプコマンド
help:
	@echo "利用可能なコマンド:"
	@echo "  make install      - 依存パッケージをインストール"
	@echo "  make start        - アプリケーションを起動"
	@echo "  make test         - テストを実行"
	@echo "  make test-watch   - テストを監視モードで実行"
	@echo "  make clean        - node_modulesを削除"

# 依存パッケージのインストール
install:
	@echo "📦 依存パッケージをインストールしています..."
	@npm install
	@echo "✅ インストール完了"

# アプリケーションの起動
start:
	@echo "🚀 アプリケーションを起動します - ポート: $(PORT)"
	@npm start

# テストの実行
test:
	@echo "🧪 テストを実行します..."
	@npm test

# テストの監視モード実行
test-watch:
	@echo "👀 テストを監視モードで実行します..."
	@npm run test:watch

# クリーンアップ
clean:
	@echo "🧹 node_modulesを削除します..."
	@rm -rf node_modules
	@echo "✅ クリーンアップ完了"

# デフォルトターゲット
.DEFAULT_GOAL := help
