import type { ChangeEvent, FC, ReactNode } from "react"

interface FloatingLabelSetupProps {
    label: string;
    newSelectClassName?: string;
    selectClassName?: string;
    newLabelClassName?: string;
    labelClassName?: string;
    name?: string;
    value?: string;
    onChange?: (e: ChangeEvent<HTMLSelectElement>) => void;
    required?: boolean;
    autoFucos?: boolean;
    disabled?: boolean;
    errors?: string[];
    children: ReactNode;
}

const FloatingLabelSelect: FC<FloatingLabelSetupProps> = ({
    label,
    newSelectClassName,
    selectClassName,
    labelClassName,
    name,
    value,
    onChange,
    required,
    autoFucos,
    disabled,
    errors,
    children
}) => {
    return (
        <>
            <div className="relative">
                <select
                    name={name}
                    id={name}
                    value={value}
                    onChange={onChange}
                    className={`${newSelectClassName
                        ? newSelectClassName
                        : `block px-2.5 pb-2.5 pt-4 w-full text-sm text-gray-900 bg-transparent rounded-lg border
                border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer 
                ${selectClassName}`
                        }`}
                    autoFocus={autoFucos}
                    disabled={disabled}
                >
                    {children}
                </select>
                <label htmlFor={name} className={newSelectClassName ? newSelectClassName : `absolute text-sm text-gray-500 dark:text-gray-400 duration-300 transform -translate-y-4 scale-75
                top-2 z-10 origin-left4 bg-white px-2 
                peer-focus:px-2 peer-focus:text-blue-600 peer-focus:dark:text-blue-500 
                peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-1/2 
                peer-focus:top-2 peer-focus:scale-75 peer-focus:-translate-y-4 
                rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto inset-s-1 ${labelClassName}}`
                }
                >
                    {label}
                    {required && <span className="text-red-600 ml-1"></span>}
                </label>
            </div>
            {errors && errors.length > 0 && (
                <span className="text-red-600">{errors[0]}</span>
            )}
        </>
    );
};

export default FloatingLabelSelect