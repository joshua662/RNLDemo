import type { FC } from "react";
import Spinner from "../Spinner/Spinner";

interface SubmitButtonProps {
  label: string;
  newClassName?: string;
  className?: string;
  loading?: boolean;
  loadingLabel?: string;
}

const SubmitButton: FC<SubmitButtonProps> = ({
  label,
  newClassName,
  className,
  loading,
  loadingLabel,
}) => {
  return (
    <>
      <button
        type="submit"
        className={`${
          newClassName
            ? newClassName
            : `inline-flex items-center justify-center gap-2 px-4 py-3 bg-green-600 hover:bg-green-700 text-white font-medium cursor-pointer rounded-lg shadow-lg ${className}`
        }`}
        disabled={loading}
      >
        {loading ? (
          <>
            <Spinner size="xs" />
            {loadingLabel}
          </>
        ) : (
          label
        )}
      </button>
    </>
  );
};

export default SubmitButton;
