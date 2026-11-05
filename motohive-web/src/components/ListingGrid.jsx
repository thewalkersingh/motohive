import  { useState, useEffect } from 'react';
import { listingService } from '../services/listingService';
import ListingCard from './ListingCard';

function ListingGrid() {
   const [listings, setListings] = useState([]);
   const [loading, setLoading] = useState(true);
   const [error, setError] = useState(null);

   useEffect(() => {
      const fetchListings = async () => {
         try {
            setLoading(true);
            const data = await listingService.getAllListings();
            setListings(data);
         } catch (err) {
            console.error("Error fetching listings:", err);
            setError("Failed to load premium listings. Please try again later.");
         } finally {
            setLoading(false);
         }
      };

      fetchListings();
   }, []);

   if (loading) {
      return <div className="loading-state">🔄 Loading premium listings...</div>;
   }

   if (error) {
      return <div className="error-state">❌ {error}</div>;
   }

   if (listings.length === 0) {
      return (
          <div className="empty-state">
             <h3>No listings found</h3>
             <p>Check back soon for premium two-wheelers!</p>
          </div>
      );
   }

   return (
       <div className="listing-grid">
          {listings.map((listing) => (
              <ListingCard key={listing.id} listing={listing} />
          ))}
       </div>
   );
}

export default ListingGrid;