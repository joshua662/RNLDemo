import AxiosInstance from "./AxiosInstance";

interface LoginData {
  username: string;
  password: string;
}

const AuthService = {
  login: async (data: LoginData) => {
    const response = await AxiosInstance.post("/auth/login", data);
    return response;
  },
  logout: async () => {
    const response = await AxiosInstance.post("/auth/logout");
    return response;
  },
  me: async () => {
    const response = await AxiosInstance.get("/auth/me");
    return response;
  },
};

export default AuthService;