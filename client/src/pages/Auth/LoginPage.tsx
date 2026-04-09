import ToastMessage from "../../components/ToastMessage/ToastMessage"
import { useToastMessage } from "../../hooks/useToastMessage"
import AuthPageLayout from "./AuthPageLayout"
import LoginForm from "./components/LoginForm"
import { useAuth } from "../../contexts/AuthContext"
import { Navigate } from "react-router-dom"

const LoginPage = () => {
    const {message, isFailed, isVisible, showToastMessage, closeToastMessage} = useToastMessage("", false, false);
    const { user, loading } = useAuth()

    if (!loading && user && !isVisible) {
        return <Navigate to="/genders" replace />
    }

  return (
    <>
    <AuthPageLayout>
        <ToastMessage message={message} isFailed={isFailed} isVisible={isVisible} onClose={closeToastMessage} />
        <LoginForm message={showToastMessage}/>
    </AuthPageLayout>
    </>
  )
}

export default LoginPage