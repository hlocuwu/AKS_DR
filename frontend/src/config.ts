// filepath: /workspaces/cloudops-practice/frontend/src/config.ts
interface AppConfig {
  API_BASE_URL: string;
}

const config: AppConfig = {
  // QUAN TRỌNG: Dùng đường dẫn tương đối "/api"
  // Trình duyệt sẽ tự động gọi vào: <Domain_Hien_Tai>/api
  // Ví dụ: http://cloudops-practice-tm.../api
  API_BASE_URL: "/api",
};

export default config;