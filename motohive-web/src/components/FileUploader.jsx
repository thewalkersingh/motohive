import React, {useState} from 'react';

function FileUploader({onUploadSuccess, mediaType = 'IMAGE'}) {
   const [uploading, setUploading] = useState(false);
   const [error, setError] = useState('');

   const handleFileChange = async (e) => {
      const file = e.target.files[0];
      if (!file) return;

      setUploading(true);
      setError('');

      const formData = new FormData();
      formData.append('file', file);
      formData.append('mediaType', mediaType);

      try {
         const response = await fetch('/api/v1/media/upload', {
            method: 'POST',
            body: formData,
         });

         const data = await response.json();

         if (!response.ok) {
            throw new Error(data.error || 'Upload failed');
         }

         onUploadSuccess(data); // Pass { url, publicId, mediaType } to parent
      } catch (err) {
         console.error('Upload error:', err);
         setError(err.message);
      } finally {
         setUploading(false);
         e.target.value = ''; // Reset input
      }
   };

   return (
       <div className="file-uploader">
          <label className="upload-btn">
             {uploading ? '⏳ Uploading...' : `📎 Upload ${mediaType}`}
             <input
                 type="file"
                 accept={mediaType === 'IMAGE' ? 'image/*' : mediaType === 'VIDEO' ? 'video/*' : '.pdf,.doc,.docx'}
                 onChange={handleFileChange}
                 disabled={uploading}
                 style={{display: 'none'}}
             />
          </label>
          {error && <p className="upload-error">❌ {error}</p>}
       </div>
   );
}

export default FileUploader;