import type { ChangeEvent, FC } from "react";

interface FloatingLabelInputProps {
    label: string;
    type: "text" | "date" | "password";
    name: string;
    value?: string;
    onChange?: (e: ChangeEvent<HTMLInputElement>) => void
    newLabelClassName?: string;
    labelClassName?: string;
    newInputClassName?: string;
    inputClassName?: string;
    required?: boolean;
    autoFocus?: boolean;
    disabled?: boolean;
    readOnly?: boolean;
    errors?: string[];
}

const FloatingLabelInput: FC<FloatingLabelInputProps> = ({
    label,
    type,
    name,
    value,
    onChange,
    newLabelClassName,
    labelClassName,
    newInputClassName,
    inputClassName,
    required,
    autoFocus,
    disabled,
    readOnly,
    errors,
}) => {
    return (
        <>
            <div className="relative">
                <input
                    type={type}
                    id={name}
                    name={name}
                    value={value}
                    onChange={onChange}
                    className={`${newInputClassName ? newInputClassName : `block px-2.5 pb-2.5 pt-4 w-full text-sm text-gray-900 bg-transparent rounded-lg border
                border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer
                ${inputClassName}
                `}`}
                    placeholder=" "
                    required={required}
                    autoFocus={autoFocus}
                    disabled={disabled}
                    readOnly={readOnly}
                />
                <label
                    htmlFor={name}
                    className={`${newLabelClassName ? newLabelClassName : `absolute text-sm text-gray-500 dark:text-gray-400 duration-300 transform -translate-y-4 scale-75
                top-2 z-10 origin-left4 bg-white px-2 
                peer-focus:px-2 peer-focus:text-blue-600 peer-focus:dark:text-blue-500 
                peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-1/2 
                peer-focus:top-2 peer-focus:scale-75 peer-focus:-translate-y-4 
                rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto inset-s-1 ${labelClassName}`
                        }`}
                >
                    {label}
                    {required && (
                        <span className="text-red-600" ml-1>*</span>

                    )}
                </label>
                {errors && errors.length > 0 && (
                    <span className="text-red-600">{errors[0]}</span>
                )}
            </div>
        </>
    )
}

export default FloatingLabelInput