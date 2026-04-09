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

export interface UpdateUserPayload {
    first_name: string;
    middle_name?: string;
    last_name: string;
    suffix_name?: string;
    gender: string;
    birth_date: string;
    username: string;
}

const UserService = {
    loadUsers: async (page: number) => {
        const response = await AxiosInstance.get(`/user/loadUsers?page=${page}`);
        return response;
    },

    storeUser: async (data: UserPayload) => {
        const response = await AxiosInstance.post("/user/storeUser", data);
        return response;
    },

    updateUser: async (userId: string | number, data: UpdateUserPayload) => {
        const response = await AxiosInstance.put(`/user/updateUser/${userId}`, data);
        return response;
    },
    destroyUser: async (userId: string | number) => {
        const response = await AxiosInstance.delete(`/user/destroyUser/${userId}`);
        return response;
    },
 };

export default UserService;