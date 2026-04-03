import ToastMessage from "../../components/ToastMessage/ToastMessage";
import { useModal } from "../../hooks/useModal";
import { useToastMessage } from "../../hooks/useToastMessage";
import AddUserFormModal from "./components/AddUserFormModal";
import UserList from "./components/UserList";

const UserMainPage = () => {
    const { isOpen, openModal, closeModal } = useModal(false);
    const { message: toastMessage, isVisible: toastMessageIsVisible, showToastMessage, closeToastMessage } = useToastMessage("", false);

    return (
        <>
            <ToastMessage message={toastMessage} isVisible={toastMessageIsVisible} onClose={closeToastMessage} />
            <AddUserFormModal isOpen={isOpen} onClose={closeModal} onUserAdded={showToastMessage} /> {/* ✅ fixed */}
            <UserList onAddUser={openModal} />
        </>
    );
};

export default UserMainPage;