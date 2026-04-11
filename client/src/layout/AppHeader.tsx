import { useNavigate } from "react-router-dom";
import { useHeader } from "../contexts/HeaderContext";
import { useSidebar } from "../contexts/SidebarContext";
import { useAuth } from "../contexts/AuthContext";
import { useState, type FormEvent } from "react";
import Modal from "../components/Modal";

const DEFAULT_AVATAR =
  "https://flowbite.com/docs/images/people/profile-picture-5.jpg";

const AppHeader = () => {
  const { isOpen, toggleUserMenu } = useHeader();
  const { toggleSidebar } = useSidebar();
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);

  const handleLogout = async (e: FormEvent) => {
    try {
      e.preventDefault();
      setIsLoading(true);
      await logout();
      toggleUserMenu();
      navigate("/");
    } catch (error) {
      console.error(
        "Unexpected server error occured during logging user out: ",
        error,
      );
    } finally {
      setIsLoading(false);
    }
  };

  const handleUserFullNameFormat = () => {
    if (!user) return "";
    let fullName = `${user.user.last_name}, ${user.user.first_name}`;
    if (user.user.middle_name) {
      fullName += ` ${user.user.middle_name.charAt(0)}.`;
    }
    if (user.user.suffix_name) {
      fullName += ` ${user.user.suffix_name}`;
    }
    return fullName;
  };

  const avatarSrc =
    user?.user.profile_picture && user.user.profile_picture.length > 0
      ? user.user.profile_picture
      : DEFAULT_AVATAR;

  return (
    <>
      <Modal
        isOpen={isOpen}
        onClose={() => !isLoading && toggleUserMenu()}
        showCloseButton
        className="w-full max-w-[min(100%,300px)] overflow-hidden rounded-[1.75rem] border border-border-muted shadow-[0_16px_48px_rgba(0,0,0,0.1)] ring-1 ring-border-muted sm:max-w-[300px] md:max-w-[300px] lg:max-w-[300px]"
        backdropClassName="fixed inset-0 h-full w-full bg-gradient-to-b from-primary-muted/90 via-surface to-primary-muted/40 backdrop-blur-sm"
        bodyClassName="px-6 pb-8 pt-10 sm:px-8"
      >
        <div className="text-center">
          <h2 className="mb-6 text-left text-lg font-bold text-ink">Profile</h2>

          <div className="mx-auto mb-4 flex h-[4.75rem] w-[4.75rem] shrink-0 items-center justify-center overflow-hidden rounded-full bg-primary-muted shadow-lg ring-4 ring-surface-card">
            <img
              src={avatarSrc}
              alt=""
              className="h-full w-full object-cover"
            />
          </div>

          <p className="text-lg font-bold leading-tight text-ink">
            {handleUserFullNameFormat()}
          </p>
          {user && (
            <>
              <p className="mt-2 text-sm font-normal text-neutral">
                @{user.user.username}
              </p>
              <p className="mt-2 flex items-center justify-center gap-1.5 text-xs text-neutral-subtle">
                <span>{user.user.gender.gender}</span>
                <span className="text-border" aria-hidden>
                  •
                </span>
                <svg
                  className="h-3.5 w-3.5 text-accent"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  aria-hidden
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                  />
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                  />
                </svg>
                <span>Signed in</span>
              </p>
            </>
          )}

          <div className="mx-auto mt-8 max-w-[220px] border-t border-border pt-6">
            <form onSubmit={handleLogout}>
              <button
                type="submit"
                disabled={isLoading}
                className="inline-flex w-full items-center justify-center gap-2 rounded-full bg-red-600 px-5 py-3 text-sm font-semibold text-white shadow-md transition hover:bg-red-700 focus:outline-none focus:ring-4 focus:ring-red-300/60 disabled:cursor-not-allowed disabled:opacity-60"
              >
                <svg
                  className="h-4 w-4 shrink-0"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  aria-hidden
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
                  />
                </svg>
                {isLoading ? "Signing out…" : "Sign Out"}
              </button>
            </form>
          </div>
        </div>
      </Modal>

      <nav className="fixed top-0 z-50 w-full border-b border-white/20 bg-white dark:bg-gray-800">
        <div className="px-3 py-3 lg:px-5 lg:pl-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center justify-start rtl:justify-end">
              <button
                type="button"
                onClick={toggleSidebar}
                className="rounded-base border border-transparent bg-transparent p-2 text-sm font-medium text-white hover:bg-white/10 focus:outline-none focus:ring-4 focus:ring-accent/35 sm:hidden"
              >
                <span className="sr-only">Open sidebar</span>
                <svg
                  className="h-6 w-6"
                  aria-hidden="true"
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  fill="none"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke="currentColor"
                    strokeLinecap="round"
                    strokeWidth="2"
                    d="M5 7h14M5 12h14M5 17h10"
                  />
                </svg>
              </button>
              <a href="https://flowbite.com" className="ms-2 flex md:me-24">
                <img
                  src="https://flowbite.com/docs/images/logo.svg"
                  className="me-3 h-6 brightness-0 invert"
                  alt="FlowBite Logo"
                />
                <span className="self-center whitespace-nowrap text-lg font-semibold text-white">
                  Flowbite
                </span>
              </a>
            </div>
            <div className="flex items-center">
              <div className="relative ms-3 flex items-center">
                <button
                  type="button"
                  onClick={toggleUserMenu}
                  className="flex rounded-full ring-[3px] ring-neutral/40 transition hover:ring-accent/70 focus:outline-none focus:ring-4 focus:ring-accent/50"
                  aria-expanded={isOpen}
                  aria-haspopup="dialog"
                >
                  <span className="sr-only">Open profile</span>
                  <img
                    className="h-9 w-9 rounded-full object-cover"
                    src={avatarSrc}
                    alt=""
                  />
                </button>
              </div>
            </div>
          </div>
        </div>
      </nav>
    </>
  );
};

export default AppHeader;
