// filepath: /workspaces/cloudops-practice/backend/src/swagger.js
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'CloudOps Practice API',
      version: '1.0.0',
    },
    // THÊM: Cấu hình servers để nút "Try it out" gọi đúng vào /api
    servers: [
      {
        url: '/api',
        description: 'Default Server'
      }
    ],
  },
  apis: ['./src/routes/*.js'], // Đường dẫn tới các file route
};

const swaggerSpec = swaggerJsdoc(options);

function setupSwagger(app) {
  // SỬA: Đổi '/api-docs' thành '/api/api-docs'
  // Vì Ingress trỏ /api vào backend và giữ nguyên path, nên app phải hứng đúng path này
  app.use('/api/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
    swaggerOptions: {
      defaultModelsExpandDepth: -1  // 👈 Ẩn hoàn toàn phần Schemas
    }
  }));
}

module.exports = setupSwagger;