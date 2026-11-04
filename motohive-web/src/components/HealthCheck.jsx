import {useState, useEffect} from 'react';

function HealthCheck() {
   const [status, setStatus] = useState('loading');
   const [data, setData] = useState(null);
   const [error, setError] = useState(null);

   useEffect(() => {
      const checkHealth = async () => {
         try {
            // Because of the Vite proxy, we just call '/api/...'
            // and it routes to http://localhost:8080/api/...
            const response = await fetch('/api/v1/health');

            if (!response.ok) {
               throw new Error(`HTTP error! status: ${response.status}`);
            }

            const jsonData = await response.json();
            setData(jsonData);
            setStatus('success');
         } catch (err) {
            console.error("Health check failed:", err);
            setError(err.message);
            setStatus('error');
         }
      };

      checkHealth();
   }, []);

   return (
       <div className="health-card">
          <h2>Backend Connectivity Status</h2>

          {status === 'loading' && (
              <p className="status loading">🔄 Connecting to Spring Boot API...</p>
          )}

          {status === 'error' && (
              <div className="status error">
                 <p>❌ Connection Failed!</p>
                 <small>Error: {error}</small>
              </div>
          )}

          {status === 'success' && (
              <div className="status success">
                 <p>✅ {data.message}</p>
                 <div className="details">
                    <span><strong>System Status:</strong> {data.status}</span>
                    <span><strong>Server Time:</strong> {new Date(data.timestamp).toLocaleString()}</span>
                 </div>
              </div>
          )}
       </div>
   );
}

export default HealthCheck;