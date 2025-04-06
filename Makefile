# デフォルトのシェルをbashに設定
SHELL := /bin/bash

# AWS関連の設定
AWS_REGION ?= ap-northeast-1
AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY_NAME ?= k8s-api-sample
IMAGE_TAG ?= latest

# 環境変数の設定
export PORT ?= 3000
export CURRENT_ENV ?= development
export CONFIG_MESSAGE ?= "テスト用ConfigMapメッセージ"
export SECRET_KEY ?= "テスト用シークレット"

.PHONY: help install start test test-watch clean docker-build docker-push ecr-login

# ヘルプコマンド
help:
	@echo "利用可能なコマンド:"
	@echo "  make install      - 依存パッケージをインストール"
	@echo "  make start        - アプリケーションを起動"
	@echo "  make test         - テストを実行"
	@echo "  make test-watch   - テストを監視モードで実行"
	@echo "  make clean        - node_modulesを削除"
	@echo "  make docker-build - Dockerイメージをビルド"
	@echo "  make docker-push  - ECRにイメージをプッシュ"
	@echo "  make ecr-login    - ECRにログイン"

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

# ECRログイン
ecr-login:
	@echo "🔐 ECRにログインします..."
	@aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
	@echo "✅ ECRログイン完了"

# Dockerイメージのビルド
docker-build:
	@echo "🏗️  Dockerイメージをビルドします..."
	@docker build -t $(ECR_REPOSITORY_NAME):$(IMAGE_TAG) .
	@docker tag $(ECR_REPOSITORY_NAME):$(IMAGE_TAG) $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(ECR_REPOSITORY_NAME):$(IMAGE_TAG)
	@echo "✅ Dockerイメージのビルド完了"

# ECRへのプッシュ
docker-push: ecr-login
	@echo "⬆️  ECRにイメージをプッシュします..."
	@docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(ECR_REPOSITORY_NAME):$(IMAGE_TAG)
	@echo "✅ ECRプッシュ完了"

# デフォルトターゲット
.DEFAULT_GOAL := help
