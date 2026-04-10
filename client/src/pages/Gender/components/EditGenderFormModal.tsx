import { useEffect, useState, type FC, type FormEvent } from "react";
import axios from "axios";
import Modal from "../../../components/Modal";
import CloseButton from "../../../components/Button/CloseButton";
import SubmitButton from "../../../components/Button/SubmitButton";
import FloatingLabelInput from "../../../components/Input/FloatingLabelInput";
import GenderService from "../../../services/GenderService";
import type {
  GenderColumns,
  GenderFieldErrors,
} from "../../../interfaces/GenderInterface";

interface EditGenderFormModalProps {
  gender: GenderColumns | null;
  isOpen: boolean;
  onClose: () => void;
  onGenderUpdated: (message: string) => void;
  refreshKey: () => void;
}

const EditGenderFormModal: FC<EditGenderFormModalProps> = ({
  gender,
  isOpen,
  onClose,
  onGenderUpdated,
  refreshKey,
}) => {
  const [loadingUpdate, setLoadingUpdate] = useState(false);
  const [genderName, setGenderName] = useState("");
  const [initialGenderName, setInitialGenderName] = useState("");
  const [errors, setErrors] = useState<GenderFieldErrors>({});

  useEffect(() => {
    if (!isOpen || !gender) return;
    setGenderName(gender.gender);
    setInitialGenderName(gender.gender);
    setErrors({});
  }, [isOpen, gender]);

  const handleUpdateGender = async (e: FormEvent) => {
    e.preventDefault();
    if (!gender) return;

    const trimmedGender = genderName.trim();
    setErrors({});

    if (!trimmedGender) {
      setLoadingUpdate(true);
      setErrors({ gender: ["The gender field is required."] });
      window.setTimeout(() => setLoadingUpdate(false), 250);
      return;
    }

    if (trimmedGender === initialGenderName.trim()) {
      onGenderUpdated("No changes were made.");
      onClose();
      return;
    }

    try {
      setLoadingUpdate(true);
      const res = await GenderService.updateGender(gender.gender_id, {
        gender: trimmedGender,
      });

      if (res.status >= 200 && res.status < 300) {
        onGenderUpdated(
          typeof res.data?.message === "string"
            ? res.data.message
            : "Gender updated successfully.",
        );
        refreshKey();
        onClose();
      } else {
        console.error("Unexpected status error occured during updating gender.");
      }
    } catch (error: unknown) {
      if (axios.isAxiosError(error) && error.response?.status === 422) {
        setErrors(error.response.data.errors);
      } else {
        console.error("Unexpected server error occured during updating gender: ", error);
      }
    } finally {
      setLoadingUpdate(false);
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} showCloseButton>
      <form onSubmit={handleUpdateGender} noValidate>
        <h1 className="mb-4 border-b border-gray-100 p-4 text-2xl font-semibold">
          Edit Gender Form
        </h1>
        <div className="mb-4">
          <FloatingLabelInput
            label="Gender"
            type="text"
            name="gender"
            value={genderName}
            onChange={(e) => {
              const nextValue = e.target.value;
              setGenderName(nextValue);
              if (nextValue.trim()) setErrors({});
            }}
            errors={errors.gender}
            required
            autoFocus
          />
        </div>
        <div className="flex justify-end gap-2">
          {!loadingUpdate && <CloseButton label="Close" onClose={onClose} />}
          <SubmitButton
            label="Update Gender"
            loading={loadingUpdate}
            loadingLabel="Updating Gender..."
          />
        </div>
      </form>
    </Modal>
  );
};

export default EditGenderFormModal;
