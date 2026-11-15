// src/components/Login.jsx
import React, {useState} from 'react';
import {useNavigate, Link} from 'react-router-dom';
import {useAuth} from '../context/AuthContext';

function Login() {
   const [email, setEmail] = useState('');
   const [password, setPassword] = useState('');
   const [error, setError] = useState('');
   const [loading, setLoading] = useState(false);
   const {login} = useAuth();
   const navigate = useNavigate();

   const handleSubmit = async (e) => {
      e.preventDefault();
      setLoading(true);
      setError('');
      try {
         await login(email, password);
         navigate('/');
      } catch (err) {
         setError(err.message);
      } finally {
         setLoading(false);
      }
   };

   return (
       <div className="auth-card">
          <h2>Welcome back 👋</h2>
          <p className="auth-sub">Log in to manage your listings</p>

          {error && <div className="form-error">❌ {error}</div>}

          <form onSubmit={handleSubmit}>
             <input
                 type="email"
                 placeholder="Email"
                 value={email}
                 onChange={(e) => setEmail(e.target.value)}
                 required
             />
             <input
                 type="password"
                 placeholder="Password"
                 value={password}
                 onChange={(e) => setPassword(e.target.value)}
                 required
             />
             <button type="submit" className="btn-submit" disabled={loading}>
                {loading ? 'Logging in...' : 'Log In'}
             </button>
          </form>

          <p className="auth-switch">
             New to Motohive? <Link to="/register">Create an account</Link>
          </p>
       </div>
   );
}

export default Login;