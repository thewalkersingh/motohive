// src/components/Pagination.jsx
import React from 'react';

function Pagination({currentPage, totalPages, onPageChange}) {
   if (totalPages <= 1) return null;

   return (
       <div className="pagination">
          <button
              className="btn-page"
              disabled={currentPage === 0}
              onClick={() => onPageChange(currentPage - 1)}
          >
             ← Prev
          </button>

          <span className="page-info">
        Page {currentPage + 1} of {totalPages}
      </span>

          <button
              className="btn-page"
              disabled={currentPage >= totalPages - 1}
              onClick={() => onPageChange(currentPage + 1)}
          >
             Next →
          </button>
       </div>
   );
}

export default Pagination;