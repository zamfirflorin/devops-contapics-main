<template>
  <div id="app">
    <header v-if="isAuthenticated">
      <h1>Management Dashboard</h1>
      <nav>
        <button v-if="userRole === 'ADMIN'" :class="{ active: currentScreen === 'users' }" @click="currentScreen = 'users'">Users</button>
        <button v-if="userRole === 'ADMIN'" :class="{ active: currentScreen === 'companies' }" @click="currentScreen = 'companies'">Companies</button>
        <button :class="{ active: currentScreen === 'photos' }" @click="currentScreen = 'photos'">Photos</button>
        <button @click="logout">Logout</button>
      </nav>
    </header>

    <main>
      <div v-if="!isAuthenticated">
        <form @submit.prevent="login">
          <input v-model="credentials.username" placeholder="Username" required />
          <input v-model="credentials.password" type="password" placeholder="Password" required />
          <button type="submit">Login</button>
        </form>
      </div>
      <div v-else>
        <div v-if="currentScreen === 'users' && userRole === 'ADMIN'">
          <UserManagement />
        </div>
        <div v-else-if="currentScreen === 'companies' && userRole === 'ADMIN'">
          <CompanyManagement />
        </div>
        <div v-else-if="currentScreen === 'photos'">
          <PhotoManagement />
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import UserManagement from "./UserManagement.vue";
import CompanyManagement from "./CompanyManagement.vue";
import PhotoManagement from "./PhotoManagement.vue";
import axios from "axios";

export default {
  name: "App",
  components: {
    UserManagement,
    CompanyManagement,
    PhotoManagement, // Register the new component
  },
  data() {
    return {
      currentScreen: "photos", // Default screen (accessible to all users)
      isAuthenticated: false,
      userRole: null,
      credentials: {
        username: "",
        password: "",
      },
    };
  },
  methods: {
    async login() {
      try {
        const backendUrl = window._env_?.BACKEND_URL || 'http://localhost:8080';
        console.log('Attempting login to:', `${backendUrl}/auth/login`);
        
        const response = await axios.post(`${backendUrl}/auth/login`, this.credentials);
        console.log('Login response:', response.data);
        
        if (!response.data.token) {
          throw new Error('No token received from server');
        }
        
        this.isAuthenticated = true;
        localStorage.setItem("authToken", response.data.token);

        // Fetch user details from /auth/me
        try {
          const userDetails = await axios.get(`${backendUrl}/auth/me`, {
            headers: {
              Authorization: `Bearer ${response.data.token}`,
            },
          });
          console.log('User details:', userDetails.data);

          this.userRole = userDetails.data.role || (userDetails.data.authorities && userDetails.data.authorities[0]?.authority);

          // Set default screen based on role
          if (this.userRole === "ADMIN") {
            this.currentScreen = "users"; // Admins see users by default
          } else {
            this.currentScreen = "photos"; // Non-admins see photos by default
          }
        } catch (meError) {
          console.error('Error fetching user details:', meError);
          // Login was successful, but fetching user details failed
          // Still allow login to proceed with default role
          this.userRole = "CLIENT"; // Default role
          this.currentScreen = "photos";
        }
      } catch (error) {
        console.error('Login error:', error);
        console.error('Error details:', error.response?.data || error.message);
        alert(`Login failed: ${error.response?.data?.message || error.message || 'Please check your credentials.'}`);
      }
    },
    logout() {
      this.isAuthenticated = false;
      this.userRole = null;
      this.credentials = { username: "", password: "" };
    },
  },
};
</script>

<style>
/* General Styles */
body {
  font-family: Arial, sans-serif;
  margin: 0;
  padding: 0;
  background-color: #f4f4f9;
  color: #333;
}

#app {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

/* Header Styles */
header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #007bff;
  color: white;
  padding: 10px 20px;
  border-radius: 8px;
  margin-bottom: 20px;
}

header h1 {
  margin: 0;
  font-size: 1.5rem;
}

nav {
  display: flex;
  gap: 10px;
}

nav button {
  background-color: white;
  color: #007bff;
  border: 1px solid #007bff;
  border-radius: 5px;
  padding: 5px 10px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.3s, color 0.3s;
}

nav button.active {
  background-color: #0056b3;
  color: white;
}

nav button:hover {
  background-color: #0056b3;
  color: white;
}

/* Main Content Styles */
main {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
</style>