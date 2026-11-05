
function ListingCard({ listing }) {
   // Find the primary image, or fallback to the first image, or a placeholder
   const primaryImage = listing.media?.find(m => m.isPrimary)?.url ||
       listing.media?.[0]?.url ||
       'https://unsplash.com/photos/a-motorcycle-parked-on-a-road-M09IGxkrStk';

   // Format price in Indian Rupees (adjust locale/currency as needed)
   const formattedPrice = new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0,
   }).format(listing.price);

   return (
       <div className="listing-card">
          <div className="listing-image-container">
             <img src={primaryImage} alt={listing.title} className="listing-image" />
             <span className={`condition-badge ${listing.condition.toLowerCase()}`}>
          {listing.condition.replace('_', ' ')}
        </span>
          </div>

          <div className="listing-details">
             <h3 className="listing-title">{listing.title}</h3>
             <p className="listing-price">{formattedPrice}</p>

             <div className="listing-specs">
                <span className="spec-item">📅 {listing.yearOfManufacture}</span>
                <span className="spec-item">⚙️ {listing.engineCc}cc</span>
                <span className="spec-item">🛣️ {(listing.mileageKm || 0).toLocaleString()} km</span>
             </div>

             <div className="listing-seller">
                <small>Sold by: <strong>{listing.seller.fullName}</strong> ({listing.seller.role})</small>
             </div>

             <div className="listing-status">
          <span className={`status-tag ${listing.inspectionStatus.toLowerCase()}`}>
            Inspection: {listing.inspectionStatus}
          </span>
             </div>
          </div>
       </div>
   );
}

export default ListingCard;