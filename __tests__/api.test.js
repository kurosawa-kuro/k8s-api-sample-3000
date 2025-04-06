const request = require('supertest');
const app = require('../index');

describe('API Tests', () => {
  // ヘルスチェックのテスト
  describe('GET /healthz', () => {
    it('should return ok', async () => {
      const response = await request(app).get('/healthz');
      expect(response.status).toBe(200);
      expect(response.text).toBe('ok');
    });
  });

  // 投稿関連のテスト
  describe('GET /posts', () => {
    it('should return posts array', async () => {
      const response = await request(app).get('/posts');
      expect(response.status).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
      expect(response.body[0]).toHaveProperty('id');
      expect(response.body[0]).toHaveProperty('title');
      expect(response.body[0]).toHaveProperty('content');
    });
  });

  describe('POST /posts', () => {
    it('should create a new post', async () => {
      const newPost = {
        title: 'テスト投稿',
        content: 'テスト内容'
      };

      const response = await request(app)
        .post('/posts')
        .send(newPost);

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('id');
      expect(response.body.title).toBe(newPost.title);
      expect(response.body.content).toBe(newPost.content);
    });
  });

  // 環境変数のテスト
  describe('GET /env', () => {
    it('should return environment variables', async () => {
      const response = await request(app).get('/env');
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('port');
      expect(response.body).toHaveProperty('currentEnv');
    });
  });

  // ConfigMapのテスト
  describe('GET /config', () => {
    it('should return 500 when CONFIG_MESSAGE is not set', async () => {
      const response = await request(app).get('/config');
      expect(response.status).toBe(500);
      expect(response.body).toHaveProperty('error');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body.error).toContain('ConfigMap未反映');
    });
  });

  // Secretのテスト
  describe('GET /secret', () => {
    it('should return masked secret', async () => {
      const response = await request(app).get('/secret');
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('secretKey');
      expect(response.body.secretKey).toBe('****MASKED****');
    });
  });

  // エラーテスト
  describe('GET /error-test', () => {
    it('should return 500 error', async () => {
      const response = await request(app).get('/error-test');
      expect(response.status).toBe(500);
      expect(response.body).toHaveProperty('error');
      expect(response.body).toHaveProperty('detail');
    });
  });
}); 