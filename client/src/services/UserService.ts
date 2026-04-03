import AxiosInstance from "./AxiosInstance";

interface UserPayload {
    first_name: string;
    middle_name: string;
    last_name: string;
    suffix_name: string;
    gender: string;
    birth_date: string;
    username: string;
    password: string;
    password_confirmation: string;
}

const UserService = {
    storeUser: async (data: UserPayload) => {
        const response = await AxiosInstance.post("/user/storeUser", data);
        return response;
    },
};

export default UserService;