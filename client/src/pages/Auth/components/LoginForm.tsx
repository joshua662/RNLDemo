import { useState, type FormEvent } from "react";
import SubmitButton from "../../../components/Button/SubmitButton";
import FloatingLabelInput from "../../../components/Input/FloatingLabelInput";
import { useAuth } from "../../../contexts/AuthContext";
import { useNavigate } from "react-router-dom";
import type { LoginCredentialsErrorFields } from "../../../interfaces/AuthInterface";

interface LoginFormProps {
  message: (message: string, isFailed: boolean) => void; 
}

const LoginForm = ({ message }: LoginFormProps) => { 
  const [isLoading, setIsLoading] = useState(false);
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [errors, setErrors] = useState<LoginCredentialsErrorFields>({});

  const { login } = useAuth();
  const navigate = useNavigate();

  const handleLogin = async (e: FormEvent) => {
    e.preventDefault(); 
    setIsLoading(true);

    try {
      await login(username, password);
      setErrors({});
      message("Login successful.", false);
      setTimeout(() => {
        navigate("/genders");
      }, 1200);
    } catch (error: any) { // eslint-disable-line @typescript-eslint/no-explicit-any
      if (error.response && error.response.status === 401) {
        setErrors({});
        message(error.response.data.message || "The provided credentials are incorrect.", true);
      } else if (error.response && error.response.status === 422) {
        const responseErrors = error.response.data.errors || {};
        setErrors(responseErrors);
        const firstErrorKey = Object.keys(responseErrors)[0];
        const firstErrorMessage = firstErrorKey ? responseErrors[firstErrorKey]?.[0] : null;
        message(firstErrorMessage || error.response.data.message || "Please check the highlighted fields.", true);
      } else {
        console.error("Unexpected server error occured during logging user in: ", error);
        message("Unexpected server error occured during logging user in.", true);
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleLogin}> 
      <div className="mb-4">
        <FloatingLabelInput
          label="Username"
          type="text"
          name="username"
          value={username}
          onChange={(e) => setUsername(e.target.value)} 
          errors={errors.username}
          required
          autoFocus
        />
      </div>
      <div className="mb-4">
        <FloatingLabelInput
          label="Password"
          type="password"
          name="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)} 
          errors={errors.password}
          required
        />
      </div>
      <SubmitButton className="w-full" label="Sign In" loading={isLoading} loadingLabel="Signing In..." /> 
    </form>
  );
};

export default LoginForm;