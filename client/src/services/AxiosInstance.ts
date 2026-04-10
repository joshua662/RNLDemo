import axios from "axios";

const AxiosInstance = axios.create({ baseURL: "http://127.0.0.1:8000/api" });

AxiosInstance.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");

  if (token) {
    config.headers["Authorization"] = `Bearer ${token}`;
  }

  if (config.data instanceof FormData) {
    // Let the browser set multipart/form-data with the correct boundary.
    config.headers.delete("Content-Type");
  } else {
    config.headers["Content-Type"] = "application/json";
  }

  return config;
});

AxiosInstance.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response.status !== 422) {
      console.error("Unexpected response error: ", error);
    }

    return Promise.reject(error);
  },
);

export default AxiosInstance;
