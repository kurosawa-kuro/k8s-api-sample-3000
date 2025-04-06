const express = require('express');
const dotenv = require('dotenv');
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

let posts = [
  { id: 1, title: '初期投稿', content: 'ようこそ' }
];

// ------------------------
// ヘルスチェック
// ------------------------
app.get('/healthz', (req, res) => {
  console.log('[GET /healthz] ヘルスチェック受信');
  res.send('ok');
});

// ------------------------
// 投稿関連
// ------------------------
app.get('/posts', (req, res) => {
  console.log('[GET /posts] 投稿一覧取得');
  res.json(posts);
});

app.post('/posts', (req, res) => {
  const { title, content } = req.body;
  console.log('[POST /posts] 新規投稿受信:', { title, content });

  const newPost = {
    id: posts.length + 1,
    title,
    content
  };
  posts.push(newPost);

  console.log('[POST /posts] 投稿追加完了:', newPost);
  res.status(201).json(newPost);
});

// ------------------------
// 環境変数表示
// ------------------------
app.get('/env', (req, res) => {
  console.log('[GET /env] 環境変数の表示要求');
  res.json({
    port: process.env.PORT,
    currentEnv: process.env.CURRENT_ENV
  });
});

// ------------------------
// ConfigMapの検証
// ------------------------
app.get('/config', (req, res) => {
  const timestamp = new Date().toISOString();
  const configMessage = process.env.CONFIG_MESSAGE;

  if (!configMessage) {
    console.error('[GET /config] エラー: CONFIG_MESSAGE が未設定 (ConfigMapが反映されていない)');
    return res.status(500).json({
      error: 'ConfigMap未反映: CONFIG_MESSAGE が見つかりません',
      timestamp
    });
  }

  console.log('[GET /config] ConfigMap確認 - 設定内容:', configMessage, ' - 時刻:', timestamp);
  res.json({
    message: configMessage,
    timestamp
  });
});

// ------------------------
// Secretの確認
// ------------------------
app.get('/secret', (req, res) => {
  const masked = process.env.SECRET_KEY ? '****MASKED****' : '未設定';
  console.log('[GET /secret] シークレット確認 - 設定状態:', masked);
  res.json({
    secretKey: masked
  });
});

// ------------------------
// 強制エラー発生テスト
// ------------------------
app.get('/error-test', (req, res) => {
  console.error('[GET /error-test] 意図的に500エラーを発生させます');
  throw new Error('これはテスト用の強制サーバーエラーです');
});

// ------------------------
// エラーハンドリング
// ------------------------
app.use((err, req, res, next) => {
  console.error('[ERROR] ハンドルされていない例外:', err.message);
  res.status(500).json({
    error: 'サーバー内部エラーが発生しました',
    detail: err.message
  });
});

// ------------------------
// サーバ起動
// ------------------------
if (require.main === module) {
  app.listen(port, () => {
    const currentEnv = process.env.CURRENT_ENV || 'development';
    console.log(`[k8s-api-sample-3000] サーバ起動`);
    console.log(`環境: ${currentEnv}`);
    console.log(`ポート: ${port}`);
  });
}

module.exports = app;
