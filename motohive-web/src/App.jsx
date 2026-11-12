// src/App.jsx
import  { useState } from 'react';
import ListingGrid from './components/ListingGrid';
import CreateListingForm from './components/CreateListingForm';
import './App.css';

function App() {
   const [view, setView] = useState('home'); // 'home' or 'create'

   return (
       <div className="app-container">
          <header className="app-header">
             <h1>🏍️ Motohive</h1>
             <p>Trusted Marketplace for Premium Used Two-Wheelers</p>

             {/* Simple Navigation for MVP */}
             <nav className="app-nav">
                <button
                    className={`nav-btn ${view === 'home' ? 'active' : ''}`}
                    onClick={() => setView('home')}
                >
                   Browse Bikes
                </button>
                <button
                    className={`nav-btn ${view === 'create' ? 'active' : ''}`}
                    onClick={() => setView('create')}
                >
                   Sell Your Bike
                </button>
             </nav>
          </header>

          <main className="app-main">
             {view === 'home' && <ListingGrid />}
             {view === 'create' && <CreateListingForm onSuccess={() => setView('home')} />}
          </main>

          <footer className="app-footer">
             <p>Branch 5: Create Listing Form & UI Integration ✅</p>
          </footer>
       </div>
   );
}

export default App;