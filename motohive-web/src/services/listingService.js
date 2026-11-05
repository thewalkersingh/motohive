const API_BASE = '/api/v1'; // Vite proxy handles the routing to localhost:8080

export const listingService = {
   getAllListings: async () => {
      const response = await fetch(`${API_BASE}/listings`);
      if (!response.ok) {
         throw new Error(`Failed to fetch listings: ${response.statusText}`);
      }
      return response.json();
   },

   getListingById: async (id) => {
      const response = await fetch(`${API_BASE}/listings/${id}`);
      if (!response.ok) {
         throw new Error(`Failed to fetch listing: ${response.statusText}`);
      }
      return response.json();
   }
};