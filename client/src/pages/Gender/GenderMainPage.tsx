import { useEffect, useState } from "react";
import AddGenderForm from "./components/AddGenderForm";
import { GenderList } from "./components/GenderList";
import ToastMessage from "../../components/ToastMessage/ToastMessage";
import { useToastMessage } from "../../hooks/useToastMessage";
import { useRefresh } from "../../hooks/useRefresh";
import { useLocation } from "react-router-dom";
import EditGenderFormModal from "./components/EditGenderFormModal";
import DeleteGenderFormModal from "./components/DeleteGenderFormModal";
import type { GenderColumns } from "../../interfaces/GenderInterface";

const GenderMainPage = () => {
  const location = useLocation();

  const {
    message: toastMessage,
    isVisible: toastMessageIsVisible,
    showToastMessage,
    closeToastMessage,
  } = useToastMessage("", false, false);

  const { refresh, handleRefresh } = useRefresh(false);
  const [selectedGenderForEdit, setSelectedGenderForEdit] = useState<GenderColumns | null>(null);
  const [selectedGenderForDelete, setSelectedGenderForDelete] = useState<GenderColumns | null>(null);
  const [isEditGenderModalOpen, setIsEditGenderModalOpen] = useState(false);
  const [isDeleteGenderModalOpen, setIsDeleteGenderModalOpen] = useState(false);

  const openEditGenderModal = (gender: GenderColumns) => {
    setSelectedGenderForEdit(gender);
    setIsEditGenderModalOpen(true);
  };

  const closeEditGenderModal = () => {
    setSelectedGenderForEdit(null);
    setIsEditGenderModalOpen(false);
  };

  const openDeleteGenderModal = (gender: GenderColumns) => {
    setSelectedGenderForDelete(gender);
    setIsDeleteGenderModalOpen(true);
  };

  const closeDeleteGenderModal = () => {
    setSelectedGenderForDelete(null);
    setIsDeleteGenderModalOpen(false);
  };

  useEffect(() => {
    document.title = "Gender Main Page";
  }, []);

  useEffect(() => {
    if (location.state?.message) {
      showToastMessage(location.state.message);
      handleRefresh();
      window.history.replaceState({}, document.title);
    }
  }, [location.state, showToastMessage, handleRefresh]);

  return (
    <>
      <ToastMessage
        message={toastMessage}
        isVisible={toastMessageIsVisible}
        onClose={closeToastMessage}
      />
      <EditGenderFormModal
        gender={selectedGenderForEdit}
        isOpen={isEditGenderModalOpen}
        onClose={closeEditGenderModal}
        onGenderUpdated={showToastMessage}
        refreshKey={handleRefresh}
      />
      <DeleteGenderFormModal
        gender={selectedGenderForDelete}
        isOpen={isDeleteGenderModalOpen}
        onClose={closeDeleteGenderModal}
        onGenderDeleted={showToastMessage}
        refreshKey={handleRefresh}
      />
      <div className="mx-auto w-full max-w-6xl px-4 sm:px-6">
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
          <div className="w-full">
            <AddGenderForm onGenderAdded={showToastMessage} refreshKey={handleRefresh} />
          </div>
          <div className="w-full">
            <GenderList
              refreshKey={refresh}
              onEditGender={openEditGenderModal}
              onDeleteGender={openDeleteGenderModal}
            />
          </div>
        </div>
      </div>
    </>
  );
};

export default GenderMainPage;
