import { Outlet } from "react-router-dom";
import AppSidebar from "./AppSidebar";
import AppHeader from "./AppHeader";
import { SidebarProvider } from "../contexts/SidebarContext";
import { HeaderProvider } from "../contexts/HeaderContext";

const LayoutContent = () => {
    return (
        <><div>
            <AppSidebar />
        </div>
            <div>
                <AppHeader />
            </div>
            <div className="p-20 -mml-14 sm:ml-52">
                <Outlet />
            </div>
        </>
    )
}

const AppLayout = () => {
    return (
        <><HeaderProvider>
            <SidebarProvider>
                <LayoutContent />
            </SidebarProvider>
        </HeaderProvider>
        </>
    )
}

export default AppLayout;