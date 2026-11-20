// src/config.js
// In dev, Vite proxy forwards /api -> localhost:8080.
// In prod (Vercel), set VITE_API_URL to your Render backend URL.
export const API_BASE = (import.meta.env.VITE_API_URL || '/api') + '/v1';