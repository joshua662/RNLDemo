import AxiosInstance from "./AxiosInstance";

interface UserPayload {
    first_name: string;
    middle_name?: string;       // Optional — not everyone has a middle name
    last_name: string;
    suffix_name?: string;       // Optional — not everyone has a suffix
    gender: string;
    birth_date: string;
    username: string;
    password: string;
    password_confirmation: string;
}

const UserService = {
    loadUsers: async () => {
        const response = await AxiosInstance.get("/user/loadUsers");
        return response;
    },

    storeUser: async (data: UserPayload) => {
        const response = await AxiosInstance.post("/user/storeUser", data);
        return response;
    },
};

export default UserService;