import AxiosInstance from "./AxiosInstance";

interface UserPayload {
    first_name: string;
    middle_name?: string;       
    last_name: string;
    suffix_name?: string;       
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
    loadUsers: async (page: number, search = "") => {
        const keyword = search.trim();
        const query = keyword
            ? `/user/loadUsers?page=${page}&search=${encodeURIComponent(keyword)}`
            : `/user/loadUsers?page=${page}`;

        const response = await AxiosInstance.get(query);
        return response;
    },

    storeUser: async (data: UserPayload | FormData) => {
        const response = await AxiosInstance.post("/user/storeUser", data);
        return response;
    },

    updateUser: async (userId: string | number, data: UpdateUserPayload | FormData) => {
        const response = await AxiosInstance.post(`/user/updateUser/${userId}`, data);
        return response;
    },
    destroyUser: async (userId: string | number) => {
        const response = await AxiosInstance.delete(`/user/destroyUser/${userId}`);
        return response;
    },
 };

export default UserService;