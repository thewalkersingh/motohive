import { useState } from 'react'
import HealthCheck from './components/HealthCheck'
import './App.css'

function App() {
   return (
       <div className="app-container">
          <header className="app-header">
             <h1>🏍️ Motohive</h1>
             <p>Premium Used Two-Wheelers Marketplace</p>
          </header>

          <main className="app-main">
             <HealthCheck />
          </main>

          <footer className="app-footer">
             <p>Branch 1: Project Bootstrap & Connectivity ✅</p>
          </footer>
       </div>
   )
}

export default App