const API_BASE_URL = "http://127.0.0.1:8000";

// Các đường dẫn con (Endpoints)
const API_ENDPOINTS = {
    LOGIN: `${API_BASE_URL}/api/auth/login`,
    WALLETS: (userId) => `${API_BASE_URL}/api/wallets/${userId}`
};