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
};

export default GenderService;
