// src/components/SearchFilters.jsx
import React, {useState} from 'react';

function SearchFilters({onApplyFilters}) {
   const [filters, setFilters] = useState({
      keyword: '',
      make: '',
      condition: '',
      minPrice: '',
      maxPrice: '',
      minCc: '',
      maxCc: '',
      sort: 'createdAt,desc' // Default sort by newest
   });

   const handleChange = (e) => {
      setFilters({...filters, [e.target.name]: e.target.value});
   };

   const handleSubmit = (e) => {
      e.preventDefault();
      // Clean up empty strings before sending to parent
      const cleanFilters = Object.fromEntries(
          Object.entries(filters).filter(([_, v]) => v !== '')
      );
      onApplyFilters(cleanFilters);
   };

   const handleReset = () => {
      const emptyFilters = {
         keyword: '',
         make: '',
         condition: '',
         minPrice: '',
         maxPrice: '',
         minCc: '',
         maxCc: '',
         sort: 'createdAt,desc'
      };
      setFilters(emptyFilters);
      onApplyFilters({}); // Reset parent state
   };

   return (
       <form className="search-filters" onSubmit={handleSubmit}>
          <div className="filter-row">
             <input
                 type="text" name="keyword" placeholder="Search by Make, Model..."
                 value={filters.keyword} onChange={handleChange} className="filter-input search-input"
             />
             <select name="condition" value={filters.condition} onChange={handleChange} className="filter-input">
                <option value="">Any Condition</option>
                <option value="NEW">New</option>
                <option value="LIKE_NEW">Like New</option>
                <option value="GOOD">Good</option>
                <option value="FAIR">Fair</option>
             </select>
             <select name="sort" value={filters.sort} onChange={handleChange} className="filter-input">
                <option value="createdAt,desc">Newest First</option>
                <option value="price,asc">Price: Low to High</option>
                <option value="price,desc">Price: High to Low</option>
                <option value="mileageKm,asc">Lowest Mileage</option>
             </select>
          </div>

          <div className="filter-row">
             <input type="text" name="make" placeholder="Make (e.g. KTM)" value={filters.make}
                    onChange={handleChange} className="filter-input"/>
             <input type="number" name="minPrice" placeholder="Min Price" value={filters.minPrice}
                    onChange={handleChange} className="filter-input"/>
             <input type="number" name="maxPrice" placeholder="Max Price" value={filters.maxPrice}
                    onChange={handleChange} className="filter-input"/>
             <input type="number" name="minCc" placeholder="Min CC" value={filters.minCc} onChange={handleChange}
                    className="filter-input"/>
             <input type="number" name="maxCc" placeholder="Max CC" value={filters.maxCc} onChange={handleChange}
                    className="filter-input"/>

             <div className="filter-actions">
                <button type="submit" className="btn-primary">Apply</button>
                <button type="button" className="btn-secondary" onClick={handleReset}>Reset</button>
             </div>
          </div>
       </form>
   );
}

export default SearchFilters;