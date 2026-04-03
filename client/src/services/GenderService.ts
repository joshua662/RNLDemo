import AxiosInstance from "./AxiosInstance";

type StoreGenderPayload = {
  gender: string;
};

const GenderService = {
  loadGenders: async () => {
    return AxiosInstance.get("/gender/loadGenders");
  },

  storeGender: async (data: StoreGenderPayload) => {
    return AxiosInstance.post("/gender/storeGender", data);
  },
  getGender: async (genderID: string | number) => {
    return AxiosInstance.get(`/gender/getGender/${genderID}`);
  },
  updateGender: async (genderId: string | number, data: StoreGenderPayload) => {
    return AxiosInstance.put(`/gender/updateGender/${genderId}`, data);
  },

  destroyGender: async (genderId: string | number) => {
    return AxiosInstance.put(`/gender/destroyGender/${genderId}`);
  },
};

export default GenderService;
