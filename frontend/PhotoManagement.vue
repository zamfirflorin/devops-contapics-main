<template>
  <div class="photo-management">
    <h1>Photo Management</h1>

    <!-- Photo Upload Form -->
    <form @submit.prevent="uploadPhoto">
      <input type="file" @change="handleFileChange" required />
      <button type="submit">Upload Photo</button>
    </form>

    <!-- Photo List -->
    <ul>
      <li v-for="photo in photos" :key="photo.id" class="photo-item">
        <img :src="photo.url" :alt="'Photo ' + photo.id" class="photo-thumbnail" />
        <div class="photo-info">
          <p>Photo ID: {{ photo.id }}</p>
          <div class="photo-actions">
            <button @click="performOcr(photo.id)" class="ocr-btn">Extract Text</button>
            <button @click="deletePhoto(photo.id)" class="delete-btn">Delete</button>
          </div>
        </div>
        <div v-if="ocrResults[photo.id]" class="ocr-result">
          <h4>Extracted Text:</h4>
          <pre>{{ ocrResults[photo.id] }}</pre>
        </div>
        <div v-if="ocrLoading[photo.id]" class="ocr-loading">
          Processing OCR...
        </div>
      </li>
    </ul>
  </div>
</template>

<script>
import axios from "axios";
import { ref, onMounted } from "vue";

export default {
  name: "PhotoManagement",
  setup() {
    const photos = ref([]);
    const selectedFile = ref(null);
    const ocrResults = ref({});
    const ocrLoading = ref({});

    const backendUrl = window._env_.BACKEND_URL;

    // Fetch photos for the user's company
    const fetchPhotos = async () => {
      try {
        const response = await axios.get(`${backendUrl}/photos`);
        photos.value = response.data;
      } catch (error) {
        console.error("Error fetching photos:", error);
      }
    };

    // Handle file selection
    const handleFileChange = (event) => {
      selectedFile.value = event.target.files[0];
    };

    // Upload photo
    const uploadPhoto = async () => {
      if (!selectedFile.value) return;

      const formData = new FormData();
      formData.append("file", selectedFile.value);

      try {
        await axios.post(`${backendUrl}/photos`, formData, {
          headers: {
            "Content-Type": "multipart/form-data",
          },
        });
        fetchPhotos(); // Refresh photo list
        selectedFile.value = null; // Clear selection
        // Reset file input
        document.querySelector('input[type="file"]').value = '';
      } catch (error) {
        console.error("Error uploading photo:", error);
        alert("Failed to upload photo: " + (error.response?.data || error.message));
      }
    };

    // Delete photo
    const deletePhoto = async (photoId) => {
      if (!confirm("Are you sure you want to delete this photo?")) {
        return;
      }

      try {
        await axios.delete(`${backendUrl}/photos/${photoId}`);
        // Remove OCR result if exists
        delete ocrResults.value[photoId];
        fetchPhotos(); // Refresh photo list
      } catch (error) {
        console.error("Error deleting photo:", error);
        alert("Failed to delete photo: " + (error.response?.data || error.message));
      }
    };

    // Perform OCR on photo
    const performOcr = async (photoId) => {
      try {
        ocrLoading.value[photoId] = true;
        const response = await axios.post(`${backendUrl}/photos/${photoId}/ocr`);

        if (response.data.success) {
          ocrResults.value[photoId] = response.data.text || "No text found in image";
        } else {
          ocrResults.value[photoId] = "OCR failed: " + (response.data.error || "Unknown error");
        }
      } catch (error) {
        console.error("Error performing OCR:", error);
        ocrResults.value[photoId] = "OCR failed: " + (error.response?.data || error.message);
      } finally {
        ocrLoading.value[photoId] = false;
      }
    };

    onMounted(fetchPhotos);

    return {
      photos,
      handleFileChange,
      uploadPhoto,
      deletePhoto,
      performOcr,
      ocrResults,
      ocrLoading,
    };
  },
};
</script>

<style>
.photo-management {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}
form {
  margin-bottom: 30px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}
input[type="file"] {
  margin-right: 10px;
}
button {
  margin-left: 5px;
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}
form button {
  background-color: #007bff;
  color: white;
}
form button:hover {
  background-color: #0056b3;
}
ul {
  list-style: none;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
}
.photo-item {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 15px;
  background: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  align-items: center;
}
.photo-thumbnail {
  width: 200px;
  height: 200px;
  object-fit: cover;
  border: 1px solid #ccc;
  border-radius: 5px;
  margin-bottom: 10px;
}
.photo-info {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 10px;
}
.photo-info p {
  margin: 0;
  font-size: 14px;
  color: #666;
}
.photo-actions {
  display: flex;
  gap: 10px;
}
.ocr-btn {
  background-color: #28a745;
  color: white;
  flex: 1;
}
.ocr-btn:hover {
  background-color: #218838;
}
.delete-btn {
  background-color: #dc3545;
  color: white;
  flex: 1;
}
.delete-btn:hover {
  background-color: #c82333;
}
.ocr-result {
  width: 100%;
  margin-top: 15px;
  padding: 10px;
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 4px;
}
.ocr-result h4 {
  margin: 0 0 10px 0;
  font-size: 14px;
  color: #333;
}
.ocr-result pre {
  margin: 0;
  white-space: pre-wrap;
  word-wrap: break-word;
  font-size: 13px;
  color: #555;
  max-height: 200px;
  overflow-y: auto;
}
.ocr-loading {
  width: 100%;
  text-align: center;
  padding: 10px;
  color: #007bff;
  font-style: italic;
}
</style>