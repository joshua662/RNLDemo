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
    <>
      <div
        className={`fixed top-5 left-5 z-9999 flex w-[92%] max-w-md items-center gap-3 rounded-xl border p-4 text-sm shadow-md ${
          isFailed
            ? "border-red-200 bg-rose-100/90 text-red-900"
            : "border-green-200 bg-emerald-100/90 text-green-900"
        }`}
        role="alert"
      >
        <div
          className={`inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-full ${
            isFailed ? "bg-red-500 text-white" : "bg-green-500 text-white"
          }`}
        >
          {isFailed ? (
            <>
          <svg
              className="h-4 w-4" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20" >
            <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 11.793a1 1 0 1 1-1.414 1.414L10 11.414l-2.293 2.293a1 1 0 0 1-1.414-1.414L8.586 10 6.293 7.707a1 1 0 0 1 1.414-1.414L10 8.586l2.293-2.293a1 1 0 0 1 1.414 1.414L11.414 10l2.293 2.293Z"/>
          </svg>
            </>
          ) : (
            <>
            <svg
              className="h-4 w-4"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L10.586 13.293l3.293-3.293a1 1 0 0 1 1.414 1.414Z" />
            </svg>
            <span className="sr-only">Check icon</span>
            
            </>
          )}
        </div>
        <div className="font-medium">{message}</div>
      </div>
    </>
  );
};

export default ToastMessage;
