import { Route, Routes } from "react-router-dom";
import AppLayout from "../layout/AppLayout";
import EditGenderPage from "../pages/Gender/EditGenderPage";
import MainPage from "../pages/Gender/MainPage";
import DeleteGenderPage from "../pages/Gender/components/DeleteGenderPage";

const AppRoutes = () => {
    return (
        <Routes>
            <Route element={<AppLayout />}>
                <Route path="/" element={<MainPage />} />
                <Route path="/gender/edit" element={<EditGenderPage />} />
                <Route path="/gender/delete" element={<DeleteGenderPage />} />
            </Route>
        </Routes>
    );
};

export default AppRoutes;
