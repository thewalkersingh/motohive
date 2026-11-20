import {API_BASE} from '../config';

export const authService = {
   register: async (payload) => {
      const response = await fetch(`${API_BASE}/auth/register`, {
         method: 'POST',
         headers: {'Content-Type': 'application/json'},
         body: JSON.stringify(payload),
      });
      if (!response.ok) {
         const err = await response.json().catch(() => ({}));
         throw new Error(err.message || 'Registration failed');
      }
      return response.json(); // { token, userId, email, role }
   },

   login: async (email, password) => {
      const response = await fetch(`${API_BASE}/auth/login`, {
         method: 'POST',
         headers: {'Content-Type': 'application/json'},
         body: JSON.stringify({email, password}),
      });
      if (!response.ok) throw new Error('Invalid email or password');
      return response.json();
   }
};