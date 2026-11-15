// src/App.jsx
import React from 'react';
import {BrowserRouter, Routes, Route, Link, useNavigate} from 'react-router-dom';
import {AuthProvider, useAuth} from './context/AuthContext';
import ListingGrid from './components/ListingGrid';
import CreateListingForm from './components/CreateListingForm';
import Login from './components/Login';
import Register from './components/Register';
import ProtectedRoute from './components/ProtectedRoute';
import './App.css';

function Navbar() {
   const {isAuthenticated, user, logout} = useAuth();
   const navigate = useNavigate();

   const handleLogout = () => {
      logout();
      navigate('/');
   };

   return (
       <nav className="app-nav">
          <Link to="/" className="nav-link">Browse Bikes</Link>

          {isAuthenticated ? (
              <>
                 <Link to="/sell" className="nav-link">Sell Your Bike</Link>
                 <span className="nav-user">Hi, {user.email.split('@')[0]}</span>
                 <button className="nav-btn-logout" onClick={handleLogout}>Logout</button>
              </>
          ) : (
              <>
                 <Link to="/login" className="nav-link">Log In</Link>
                 <Link to="/register" className="nav-link nav-link-cta">Sign Up</Link>
              </>
          )}
       </nav>
   );
}

function App() {
   return (
       <AuthProvider>
          <BrowserRouter>
             <div className="app-container">
                <header className="app-header">
                   <h1>🏍️ Motohive</h1>
                   <p>Trusted Marketplace for Premium Used Two-Wheelers</p>
                   <Navbar/>
                </header>

                <main className="app-main">
                   <Routes>
                      <Route path="/" element={<ListingGrid/>}/>
                      <Route path="/login" element={<Login/>}/>
                      <Route path="/register" element={<Register/>}/>
                      <Route
                          path="/sell"
                          element={
                             <ProtectedRoute>
                                <CreateListingForm onSuccess={() => window.location.href = '/'}/>
                             </ProtectedRoute>
                          }
                      />
                   </Routes>
                </main>

                <footer className="app-footer">
                   <p>Branch 6: User Authentication & Authorization ✅</p>
                </footer>
             </div>
          </BrowserRouter>
       </AuthProvider>
   );
}

export default App;