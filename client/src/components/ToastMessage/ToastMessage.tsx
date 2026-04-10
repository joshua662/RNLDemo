import { useEffect, type FC } from "react";

interface ToastMessageProps {
  message: string;
  isFailed?: boolean;
  isVisible: boolean;
  onClose: () => void;
}
const ToastMessage: FC<ToastMessageProps> = ({
  message,
  isFailed,
  isVisible,
  onClose,
}) => {
  useEffect(() => {
    if (isVisible) {
      const timer = setTimeout(() => {
        onClose();
      }, 3000);

      return () => clearTimeout(timer);
    }
  }, [isVisible, onClose]);

  if (!isVisible) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-100000 flex items-center justify-center bg-slate-200/70 p-4">
      <div
        className={`w-full max-w-sm rounded-3xl border bg-white p-8 text-center shadow-[0_20px_50px_rgba(37,99,235,0.15)] ${
          isFailed ? "border-rose-100 text-rose-500" : "border-emerald-100 text-emerald-500"
        }`}
        role="alert"
      >
        <div className="mx-auto mb-5 flex h-20 w-20 items-center justify-center rounded-full border-4 border-current/20 bg-white">
          {isFailed ? (
            <svg
              className="h-12 w-12"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 20 20"
            >
              <path
                d="M10 3.5L17 16H3L10 3.5Z"
                stroke="currentColor"
                strokeWidth="1.8"
                strokeLinejoin="round"
              />
              <path d="M10 7.8V11.3" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
              <circle cx="10" cy="13.8" r="0.9" fill="currentColor" />
            </svg>
          ) : (
            <svg
              className="h-12 w-12"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 20 20"
            >
              <circle cx="10" cy="10" r="7" stroke="currentColor" strokeWidth="1.8" />
              <path
                d="M6.8 10.1L9.1 12.2L13.4 7.9"
                stroke="currentColor"
                strokeWidth="1.8"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          )}
        </div>
        <h3 className="text-3xl font-extrabold tracking-wide">
          {isFailed ? "OH NO..." : "SUCCESS!"}
        </h3>
        <p className="mt-3 text-sm text-slate-500">{message}</p>
      </div>
    </div>
  );
};

export default ToastMessage;
