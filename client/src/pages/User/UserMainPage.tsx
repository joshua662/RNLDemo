import ToastMessage from "../../components/ToastMessage/ToastMessage";
import { useModal } from "../../hooks/useModal";
import { useRefresh } from "../../hooks/useRefresh";
import { useToastMessage } from "../../hooks/useToastMessage";
import AddUserFormModal from "./components/AddUserFormModal";
import EditUserFormModal from "./components/EditUserFormModal";
import UserList from "./components/UserList";

const UserMainPage = () => {
    const { isOpen: isAddUserFormModalOpen, openModal: openAddUserFormModal, closeModal: closeAddUserFormModal } = useModal(false);
    const { isOpen: isEditUserFormModalOpen, selectedUser, openModal: openEditUserFormModal, closeModal: closeEditUserFormModal } = useModal(false)
    const { message: toastMessage, isVisible: toastMessageIsVisible, showToastMessage, closeToastMessage } = useToastMessage("", false);
    const { refresh, handleRefresh } = useRefresh(false);

    return (
        <>
            <ToastMessage message={toastMessage} isVisible={toastMessageIsVisible} onClose={closeToastMessage} />
            <AddUserFormModal isOpen={isAddUserFormModalOpen} refreshKey={handleRefresh} onClose={closeAddUserFormModal} onUserAdded={showToastMessage} />
            <EditUserFormModal user={selectedUser} onUserUpdated={showToastMessage} refreshKey={handleRefresh} isOpen={isEditUserFormModalOpen} onClose={closeEditUserFormModal} />
            <UserList onAddUser={openAddUserFormModal} onEditUser={(user) => openEditUserFormModal(user)} refreshKey={refresh} />
        </>
    );
};

export default UserMainPage;