import { Routes, Route } from "react-router-dom"
import AppLayout from "../layout/AppLayout"

const SampleComponent = () => {
    return (
        <>
            <h1 className="text-red-600">Hello World</h1>
        </>
    )
}

const AppRoutes = () => {
    return (
        <>
            <Routes>
                <Route element={<AppLayout />}>
                    <Route path="/" element={<SampleComponent />} />
                </Route>
            </Routes>
        </>
    )
}

export default AppRoutes;