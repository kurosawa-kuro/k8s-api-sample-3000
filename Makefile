# デフォルトのシェルをbashに設定
SHELL := /bin/bash

# AWS関連の設定
AWS_REGION ?= ap-northeast-1
AWS_ACCOUNT_ID ?= 503561449641
ECR_REPOSITORY_NAME ?= k8s-api-sample
IMAGE_TAG ?= latest

# 環境変数の設定
export PORT ?= 3000
export CURRENT_ENV ?= development
export CONFIG_MESSAGE ?= "テスト用ConfigMapメッセージ"
export SECRET_KEY ?= "テスト用シークレット"

# Docker関連の設定
DOCKER_LOCAL_TAG ?= k8s-api-sample-local
DOCKER_LOCAL_PORT ?= 3000

.PHONY: help install start test test-watch clean docker-build docker-push ecr-login check-aws-credentials docker-local-build docker-local-run docker-local-stop

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
	@echo "  make check-aws-credentials - AWS認証情報を確認"
	@echo "  make docker-local-build - ローカル用Dockerイメージをビルド"
	@echo "  make docker-local-run   - ローカルでDockerコンテナを実行"
	@echo "  make docker-local-stop  - ローカルで実行中のDockerコンテナを停止"

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

# AWS認証情報の確認
check-aws-credentials:
	@echo "🔍 AWS認証情報を確認します..."
	@aws sts get-caller-identity || (echo "❌ AWS認証情報が無効です" && exit 1)
	@echo "✅ AWS認証情報が有効です"
	@echo "📝 現在の設定:"
	@echo "   - リージョン: $(AWS_REGION)"
	@echo "   - アカウントID: $(AWS_ACCOUNT_ID)"
	@echo "   - リポジトリ: $(ECR_REPOSITORY_NAME)"

# ECRログイン
ecr-login: check-aws-credentials
	@echo "🔐 ECRにログインします..."
	@aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com || (echo "❌ ECRログインに失敗しました" && exit 1)
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

# ローカル用Dockerイメージのビルド
docker-local-build:
	@echo "🏗️  ローカル用Dockerイメージをビルドします..."
	@docker build -t $(DOCKER_LOCAL_TAG):$(IMAGE_TAG) .
	@echo "✅ ローカル用Dockerイメージのビルド完了"

# ローカルでDockerコンテナを実行
docker-local-run:
	@echo "🚀 ローカルでDockerコンテナを実行します..."
	@docker run -d \
		--name $(DOCKER_LOCAL_TAG) \
		-p $(DOCKER_LOCAL_PORT):3000 \
		-e PORT=3000 \
		-e CURRENT_ENV=development \
		-e CONFIG_MESSAGE="ローカル開発用ConfigMapメッセージ" \
		-e SECRET_KEY="ローカル開発用シークレット" \
		$(DOCKER_LOCAL_TAG):$(IMAGE_TAG)
	@echo "✅ コンテナを起動しました"
	@echo "📝 アクセスURL: http://localhost:$(DOCKER_LOCAL_PORT)"

# ローカルで実行中のDockerコンテナを停止
docker-local-stop:
	@echo "🛑 ローカルで実行中のDockerコンテナを停止します..."
	@docker stop $(DOCKER_LOCAL_TAG) || true
	@docker rm $(DOCKER_LOCAL_TAG) || true
	@echo "✅ コンテナを停止しました"

# デフォルトターゲット
.DEFAULT_GOAL := help
