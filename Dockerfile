# ビルドステージ
FROM node:18-slim AS builder

# 作業ディレクトリを設定
WORKDIR /app

# package.jsonとpackage-lock.jsonをコピー
COPY package*.json ./

# 依存パッケージをインストール（開発依存パッケージも含む）
RUN npm ci

# アプリケーションのソースコードをコピー
COPY . .

# 本番ステージ
FROM node:18-slim

# 作業ディレクトリを設定
WORKDIR /app

# package.jsonとpackage-lock.jsonをコピー
COPY package*.json ./

# 本番用の依存パッケージのみをインストール
RUN npm ci --only=production

# ビルドステージからアプリケーションコードをコピー
COPY --from=builder /app/index.js ./

# 非rootユーザーを作成
RUN addgroup --system appgroup && adduser --system --group appgroup appuser
USER appuser

# アプリケーションのポートを公開
EXPOSE 3000

# 本番環境変数を設定
ENV NODE_ENV=production
ENV PORT=3000

# アプリケーションを起動
CMD ["node", "index.js"] 