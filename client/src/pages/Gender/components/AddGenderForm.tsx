import { useState, type FC, type FormEvent, } from "react";
import axios from "axios";
import FloatingLabelInput from "../../../components/Input/FloatingLabelInput";
import SubmitButton from "../../../components/Button/SubmitButton";
import GenderService from "../../../services/GenderService";
import type { GenderFieldErrors } from "../../../interfaces/GenderInterface";

interface AddGenderFormProps {
  onGenderAdded: (message: string) => void;
  refreshKey: () => void
}

const AddGenderForm: FC<AddGenderFormProps> = ({ onGenderAdded, refreshKey }) => {
  const [loadingStore, setLoadingStore] = useState(false);
  const [gender, setGender] = useState("");
  const [errors, setErrors] = useState<GenderFieldErrors>({});

  const handleStoreGender = async (e: FormEvent) => {
    try {
      e.preventDefault();

      setErrors({});

      if (!gender.trim()) {
        setErrors({
          gender: ["The gender field is required."],
        });
        setLoadingStore(true);
        window.setTimeout(() => {
          setLoadingStore(false);
        }, 250);
        return;
      }

      setLoadingStore(true);

      const res = await GenderService.storeGender({ gender });

      if (res.status >= 200 && res.status < 300) {
        setGender("");
        setErrors({});
        onGenderAdded(res.data.message);
        refreshKey();
      } else {
        console.error(
          "Unexpected error occurred during store gender: ",
          res.data,
        );
      }

      setLoadingStore(false);
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

      setLoadingStore(false);
    }
  };

  return (
    <>
      <form onSubmit={handleStoreGender} noValidate>
        <div className="mb-4">
          <FloatingLabelInput
            label="Gender"
            type="text"
            name="gender"
            value={gender}
            onChange={(e) => {
              const nextValue = e.target.value;
              setGender(nextValue);
              if (nextValue.trim()) setErrors({});
            }}
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
