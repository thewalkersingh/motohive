import  { useState } from 'react';
import FileUploader from './FileUploader';

// TODO: Replace this with a real logged-in user ID once Auth is implemented
const TEMP_SELLER_ID = "11111111-1111-1111-1111-111111111001";

function CreateListingForm({ onSuccess }) {
   const [formData, setFormData] = useState({
      title: '',
      description: '',
      price: '',
      make: '',
      model: '',
      yearOfManufacture: '',
      mileageKm: '',
      engineCc: '',
      condition: 'GOOD',
   });

   const [media, setMedia] = useState([]);
   const [loading, setLoading] = useState(false);
   const [error, setError] = useState('');

   const handleChange = (e) => {
      setFormData({ ...formData, [e.target.name]: e.target.value });
   };

   const handleUploadSuccess = (uploadData) => {
      // uploadData contains { url, publicId, mediaType }
      setMedia((prev) => [
         ...prev,
         {
            url: uploadData.url,
            mediaType: uploadData.mediaType,
            isPrimary: prev.length === 0, // First image is primary
            displayOrder: prev.length,
         },
      ]);
   };

   const removeMedia = (index) => {
      setMedia((prev) => prev.filter((_, i) => i !== index));
   };

   const handleSubmit = async (e) => {
      e.preventDefault();
      setLoading(true);
      setError('');

      const payload = {
         sellerId: TEMP_SELLER_ID,
         ...formData,
         price: parseFloat(formData.price),
         yearOfManufacture: parseInt(formData.yearOfManufacture),
         mileageKm: parseInt(formData.mileageKm),
         engineCc: parseInt(formData.engineCc),
         media: media,
      };

      try {
         const response = await fetch('/api/v1/listings', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
         });

         if (!response.ok) {
            const errData = await response.json();
            throw new Error(errData.message || 'Failed to create listing');
         }

         alert('Listing created successfully!');
         onSuccess(); // Callback to refresh the grid or navigate away
      } catch (err) {
         console.error(err);
         setError(err.message);
      } finally {
         setLoading(false);
      }
   };

   return (
       <form className="create-listing-form" onSubmit={handleSubmit}>
          <h2>Add New Premium Listing</h2>

          {error && <div className="form-error">❌ {error}</div>}

          <div className="form-section">
             <h3>Bike Details</h3>
             <div className="form-grid">
                <input name="title" placeholder="Title (e.g., 2022 KTM Duke 390)" value={formData.title} onChange={handleChange} required />
                <input name="make" placeholder="Make (e.g., KTM)" value={formData.make} onChange={handleChange} required />
                <input name="model" placeholder="Model (e.g., Duke 390)" value={formData.model} onChange={handleChange} required />
                <input name="price" type="number" placeholder="Price (INR)" value={formData.price} onChange={handleChange} required />
                <input name="yearOfManufacture" type="number" placeholder="Year" value={formData.yearOfManufacture} onChange={handleChange} required />
                <input name="mileageKm" type="number" placeholder="Mileage (km)" value={formData.mileageKm} onChange={handleChange} required />
                <input name="engineCc" type="number" placeholder="Engine CC" value={formData.engineCc} onChange={handleChange} required />

                <select name="condition" value={formData.condition} onChange={handleChange}>
                   <option value="NEW">New</option>
                   <option value="LIKE_NEW">Like New</option>
                   <option value="GOOD">Good</option>
                   <option value="FAIR">Fair</option>
                </select>
             </div>
             <textarea
                 name="description"
                 placeholder="Detailed description of the bike..."
                 value={formData.description}
                 onChange={handleChange}
                 rows="4"
             />
          </div>

          <div className="form-section">
             <h3>Upload Media</h3>
             <div className="upload-grid">
                <FileUploader onUploadSuccess={handleUploadSuccess} mediaType="IMAGE" />
                <FileUploader onUploadSuccess={handleUploadSuccess} mediaType="VIDEO" />
                <FileUploader onUploadSuccess={handleUploadSuccess} mediaType="DOCUMENT" />
             </div>

             {media.length > 0 && (
                 <div className="media-preview">
                    <h4>Attached Media ({media.length})</h4>
                    <ul>
                       {media.map((m, index) => (
                           <li key={index}>
                              <span className="media-type-badge">{m.mediaType}</span>
                              <span className="media-url" title={m.url}>{m.url.substring(0, 40)}...</span>
                              <button type="button" className="btn-remove" onClick={() => removeMedia(index)}>✕</button>
                           </li>
                       ))}
                    </ul>
                 </div>
             )}
          </div>

          <button type="submit" className="btn-submit" disabled={loading}>
             {loading ? 'Publishing...' : 'Publish Listing'}
          </button>
       </form>
   );
}

export default CreateListingForm;