// src/services/listingService.js

const API_BASE = '/api/v1';

export const listingService = {
   // New method for advanced search and pagination
   searchListings: async (filters = {}, page = 0, size = 6) => {
      const params = new URLSearchParams({ page, size });

      // Append filters only if they have a value
      if (filters.keyword) params.append('keyword', filters.keyword);
      if (filters.make) params.append('make', filters.make);
      if (filters.condition) params.append('condition', filters.condition);
      if (filters.minPrice) params.append('minPrice', filters.minPrice);
      if (filters.maxPrice) params.append('maxPrice', filters.maxPrice);
      if (filters.minCc) params.append('minCc', filters.minCc);
      if (filters.maxCc) params.append('maxCc', filters.maxCc);
      if (filters.sort) params.append('sort', filters.sort);

      const response = await fetch(`${API_BASE}/listings?${params.toString()}`);
      if (!response.ok) {
         throw new Error(`Failed to fetch listings: ${response.statusText}`);
      }
      return response.json(); // Returns PageResponse structure
   },

   getListingById: async (id) => {
      const response = await fetch(`${API_BASE}/listings/${id}`);
      if (!response.ok) {
         throw new Error(`Failed to fetch listing: ${response.statusText}`);
      }
      return response.json();
   }
};