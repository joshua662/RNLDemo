import { Link } from "react-router-dom";
import { useSidebar } from "../contexts/SidebarContext";

const AppSidebar = () => {
    const { isOpen, toggleSidebar } = useSidebar();

    const sidebarItems = [
        {
            path: '/',
            text: 'Gender',
        },
        {
            path: '/users',
            text: 'User',
        }
    ]

    return (
        <>
            {!isOpen && (
                <div
                    className="fixed inset-0 z-30 blur-lg sm:hidden"
                    onClick={toggleSidebar}
                />
            )}
            <aside
                id="logo-sidebar"
                className={`fixed top-0 left-0 z-40 w-64 h-screen pt-20 transition-transform 
                    ${isOpen ? "-translate-x-full" : "translate-x-0"}
                bg-white border-r border-gray-200 sm:translate-x-0 dark:bg-gray-800 dark:border-gray-700`}
                aria-label="Sidebar"
            >
                <div className="h-full px-3 pb-4 overflow-y-auto bg-white dark:bg-gray-800">
                    <ul className="space-y-2 font-medium">
                        {sidebarItems.map((sidebarItem, index) => (
                            <li key={index}>
                                <Link
                                    to={sidebarItem.path}
                                    className="flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group"
                                >
                                    <span className="ms-3">{sidebarItem.text}</span>
                                </Link>
                            </li>
                        ))}
                    </ul>
                </div>
            </aside>
        </>
    )
}

export default AppSidebar;