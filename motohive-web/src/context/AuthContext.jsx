// src/context/AuthContext.jsx
import React, {createContext, useContext, useState, useCallback} from 'react';
import {authService} from '../services/authService';
import {API_BASE} from '../config';

const AuthContext = createContext(null);

export function AuthProvider({children}) {
   const [token, setToken] = useState(() => localStorage.getItem('mh_token'));
   const [user, setUser] = useState(() => {
      const raw = localStorage.getItem('mh_user');
      return raw ? JSON.parse(raw) : null;
   });

   const persist = (jwt, userData) => {
      localStorage.setItem('mh_token', jwt);
      localStorage.setItem('mh_user', JSON.stringify(userData));
      setToken(jwt);
      setUser(userData);
   };

   const logout = useCallback(() => {
      localStorage.removeItem('mh_token');
      localStorage.removeItem('mh_user');
      setToken(null);
      setUser(null);
   }, []);

   const login = async (email, password) => {
      const data = await authService.login(email, password);
      persist(data.token, {userId: data.userId, email: data.email, role: data.role});
      return data;
   };

   const register = async (payload) => {
      const data = await authService.register(payload);
      persist(data.token, {userId: data.userId, email: data.email, role: data.role});
      return data;
   };

   // Reusable fetch that attaches the JWT and auto-logs-out on expiry
   const authFetch = useCallback(
       async (path, options = {}) => {
          const headers = {...(options.headers || {})};
          if (token) headers['Authorization'] = `Bearer ${token}`;

          const response = await fetch(`${API_BASE}${path}`, {...options, headers});

          if (response.status === 401) {
             logout();
             throw new Error('Session expired. Please log in again.');
          }
          return response;
       },
       [token, logout]
   );

   return (
       <AuthContext.Provider
           value={{
              token,
              user,
              isAuthenticated: !!token,
              login,
              register,
              logout,
              authFetch,
           }}
       >
          {children}
       </AuthContext.Provider>
   );
}

export const useAuth = () => {
   const ctx = useContext(AuthContext);
   if (!ctx) throw new Error('useAuth must be used within AuthProvider');
   return ctx;
};