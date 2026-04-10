import { useEffect, useState, type FC, type FormEvent } from "react";
import Modal from "../../../components/Modal";
import FloatingLabelInput from "../../../components/Input/FloatingLabelInput";
import CloseButton from "../../../components/Button/CloseButton";
import SubmitButton from "../../../components/Button/SubmitButton";
import GenderService from "../../../services/GenderService";
import type { GenderColumns } from "../../../interfaces/GenderInterface";

interface DeleteGenderFormModalProps {
  gender: GenderColumns | null;
  isOpen: boolean;
  onClose: () => void;
  onGenderDeleted: (message: string) => void;
  refreshKey: () => void;
}

const DeleteGenderFormModal: FC<DeleteGenderFormModalProps> = ({
  gender,
  isOpen,
  onClose,
  onGenderDeleted,
  refreshKey,
}) => {
  const [loadingDestroy, setLoadingDestroy] = useState(false);
  const [genderName, setGenderName] = useState("");

  useEffect(() => {
    if (!isOpen || !gender) return;
    setGenderName(gender.gender);
  }, [isOpen, gender]);

  const handleDestroyGender = async (e: FormEvent) => {
    e.preventDefault();
    if (!gender) return;

    try {
      setLoadingDestroy(true);
      const res = await GenderService.destroyGender(gender.gender_id);

      if (res.status >= 200 && res.status < 300) {
        onGenderDeleted(
          typeof res.data?.message === "string"
            ? res.data.message
            : "Gender deleted successfully.",
        );
        refreshKey();
        onClose();
      } else {
        console.error("Unexpected status error occured during deleting gender: ", res.status);
      }
    } catch (error) {
      console.error("Unexpected server error occured during deleting gender: ", error);
    } finally {
      setLoadingDestroy(false);
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} showCloseButton>
      <form onSubmit={handleDestroyGender}>
        <h1 className="mb-4 border-b border-gray-100 p-4 text-2xl font-semibold">
          Delete Gender Form
        </h1>
        <div className="mb-4">
          <FloatingLabelInput
            label="Gender"
            type="text"
            name="gender"
            value={genderName}
            readOnly={true}
            inputClassName="cursor-default bg-gray-50"
          />
        </div>
        <div className="flex justify-end gap-2">
          {!loadingDestroy && <CloseButton label="Close" onClose={onClose} />}
          <SubmitButton
            label="Delete Gender"
            className="bg-red-600 hover:bg-red-700"
            loading={loadingDestroy}
            loadingLabel="Deleting Gender..."
          />
        </div>
      </form>
    </Modal>
  );
};

export default DeleteGenderFormModal;
