// src/components/Register.jsx
import React, {useState} from 'react';
import {useNavigate, Link} from 'react-router-dom';
import {useAuth} from '../context/AuthContext';

function Register() {
   const [form, setForm] = useState({
      fullName: '',
      email: '',
      password: '',
      role: 'BUYER',
   });
   const [error, setError] = useState('');
   const [loading, setLoading] = useState(false);
   const {register} = useAuth();
   const navigate = useNavigate();

   const handleChange = (e) =>
       setForm({...form, [e.target.name]: e.target.value});

   const handleSubmit = async (e) => {
      e.preventDefault();
      setLoading(true);
      setError('');
      try {
         await register(form);
         navigate('/');
      } catch (err) {
         setError(err.message);
      } finally {
         setLoading(false);
      }
   };

   return (
       <div className="auth-card">
          <h2>Create your account 🏍️</h2>
          <p className="auth-sub">Join Motohive in seconds</p>

          {error && <div className="form-error">❌ {error}</div>}

          <form onSubmit={handleSubmit}>
             <input
                 name="fullName"
                 placeholder="Full Name"
                 value={form.fullName}
                 onChange={handleChange}
                 required
             />
             <input
                 type="email"
                 name="email"
                 placeholder="Email"
                 value={form.email}
                 onChange={handleChange}
                 required
             />
             <input
                 type="password"
                 name="password"
                 placeholder="Password"
                 value={form.password}
                 onChange={handleChange}
                 required
                 minLength="6"
             />

             <div className="role-toggle">
                <label className={form.role === 'BUYER' ? 'active' : ''}>
                   <input
                       type="radio"
                       name="role"
                       value="BUYER"
                       checked={form.role === 'BUYER'}
                       onChange={handleChange}
                   />
                   🛒 I want to Buy
                </label>
                <label className={form.role === 'SELLER' ? 'active' : ''}>
                   <input
                       type="radio"
                       name="role"
                       value="SELLER"
                       checked={form.role === 'SELLER'}
                       onChange={handleChange}
                   />
                   🏷️ I want to Sell
                </label>
             </div>

             <button type="submit" className="btn-submit" disabled={loading}>
                {loading ? 'Creating account...' : 'Sign Up'}
             </button>
          </form>

          <p className="auth-switch">
             Already have an account? <Link to="/login">Log in</Link>
          </p>
       </div>
   );
}

export default Register;