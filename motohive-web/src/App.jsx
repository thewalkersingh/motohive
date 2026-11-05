import React from 'react';
import ListingGrid from './components/ListingGrid';
import './App.css';

function App() {
   return (
       <div className="app-container">
          <header className="app-header">
             <h1>🏍️ Motohive</h1>
             <p>Trusted Marketplace for Premium Used Two-Wheelers</p>
          </header>

          <main className="app-main">
             <ListingGrid />
          </main>

          <footer className="app-footer">
             <p>Branch 2: Core Domain Modeling (Users & Listings) ✅</p>
          </footer>
       </div>
   );
}

export default App;