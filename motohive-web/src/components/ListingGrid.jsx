// src/components/ListingGrid.jsx
import React, { useState, useEffect } from 'react';
import { listingService } from '../services/listingService';
import ListingCard from './ListingCard';
import SearchFilters from './SearchFilters';
import Pagination from './Pagination';

function ListingGrid() {
   const [listings, setListings] = useState([]);
   const [loading, setLoading] = useState(true);
   const [error, setError] = useState(null);

   // Pagination & Filter State
   const [currentPage, setCurrentPage] = useState(0);
   const [totalPages, setTotalPages] = useState(0);
   const [filters, setFilters] = useState({});

   useEffect(() => {
      const fetchListings = async () => {
         try {
            setLoading(true);
            setError(null);
            // Fetch data with current filters and page
            const data = await listingService.searchListings(filters, currentPage, 6); // 6 items per page (3x2 grid)

            setListings(data.content);
            setTotalPages(data.totalPages);
         } catch (err) {
            console.error("Error fetching listings:", err);
            setError("Failed to load premium listings. Please try again later.");
         } finally {
            setLoading(false);
         }
      };

      fetchListings();
   }, [filters, currentPage]); // Re-fetch when filters or page changes

   const handleApplyFilters = (newFilters) => {
      setFilters(newFilters);
      setCurrentPage(0); // Reset to first page on new search
   };

   return (
       <div className="listing-section">
          <SearchFilters onApplyFilters={handleApplyFilters} />

          {loading && <div className="loading-state">🔄 Loading premium listings...</div>}

          {error && <div className="error-state">❌ {error}</div>}

          {!loading && !error && listings.length === 0 && (
              <div className="empty-state">
                 <h3>No listings found</h3>
                 <p>Try adjusting your filters or search terms.</p>
              </div>
          )}

          {!loading && !error && listings.length > 0 && (
              <>
                 <div className="listing-grid">
                    {listings.map((listing) => (
                        <ListingCard key={listing.id} listing={listing} />
                    ))}
                 </div>
                 <Pagination
                     currentPage={currentPage}
                     totalPages={totalPages}
                     onPageChange={setCurrentPage}
                 />
              </>
          )}
       </div>
   );
}

export default ListingGrid;