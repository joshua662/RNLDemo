import { useState, type FC, type FormEvent } from "react";
import axios from "axios";
import FloatingLabelInput from "../../../components/Input/FloatingLabelInput";
import SubmitButton from "../../../components/Button/SubmitButton";
import GenderService from "../../../services/GenderService";
import type { GenderFieldErrors } from "../../../interfaces/GenderFieldErrors";

interface AddGenderFormProps {
  onGenderAdded: (message: string) => void;
}

const AddGenderForm: FC<AddGenderFormProps> = ({ onGenderAdded }) => {
  const [loadingStore, setLoadingStore] = useState(false);
  const [gender, setGender] = useState("");
  const [errors, setErrors] = useState<GenderFieldErrors>({});

  const handleStoreGender = async (e: FormEvent) => {
    try {
      e.preventDefault();

      setErrors({});
      setLoadingStore(true);

      const res = await GenderService.storeGender({ gender });

      if (res.status === 200) {
        setGender("");
        setErrors({});
        onGenderAdded(res.data.message);
      } else {
        console.error(
          "Unexpected error occurred during store gender: ",
          res.data,
        );
      }
    } catch (error: unknown) {
      if (axios.isAxiosError(error)) {
        if (error.response?.status === 422) {
          setErrors(error.response.data.errors);
        } else {
          console.error(
            "Unexpected server error occured during store gender:",
            error,
          );
        }
      } else {
        console.error("Unexpected error occured during store gender:", error);
      }
    } finally {
      setLoadingStore(false);
    }
  };

  return (
    <>
      <form onSubmit={handleStoreGender}>
        <div className="mb-4">
          <FloatingLabelInput
            label="Gender"
            type="text"
            name="gender"
            value={gender}
            onChange={(e) => setGender(e.target.value)}
            required
            autoFocus
            errors={errors.gender}
          />
        </div>
        <div></div>
        <div className="flex justify-end">
          <SubmitButton
            label="Save Gender"
            loading={loadingStore}
            loadingLabel="Saving Gender..."
          />
        </div>
      </form>
    </>
  );
};

export default AddGenderForm;
