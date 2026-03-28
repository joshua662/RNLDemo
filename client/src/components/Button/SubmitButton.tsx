import type { FC } from "react"

interface SubmitButtonProps {
    label: string
    newClassName?: string
    className?: string
}

const SubmitButton: FC<SubmitButtonProps> = ({ label, newClassName, className }) => {
    return (
        <>
            <button
                type="submit"
                className={`${newClassName
                    ? newClassName
                    : `px-4 py-3 bg-green-600 hover:bg-green-700 text-white font-medium cursor-pointer rounded-lg shadow-lg ${className}`
                    }`}
            >
                {label}
            </button>
        </>
    );
};

export default SubmitButton;