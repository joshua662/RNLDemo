import type { AxiosResponse } from "axios";
import AxiosInstance from "./AxiosInstance";

type StoreGenderPayload = {
  gender: string;
};

const GenderService = {
  storeGender: async (
    data: StoreGenderPayload,
  ): Promise<AxiosResponse<{ message: string }>> => {
    return AxiosInstance.post("/gender/storeGender", data);
  },
};

export default GenderService;
