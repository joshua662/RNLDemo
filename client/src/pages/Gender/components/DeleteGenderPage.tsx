import { useEffect } from "react"
import DeleteGenderForm from "./DeleteGenderForm"

const DeleteGenderPage = () => {
    useEffect(() => {
        document.title = "Gender Delete Page";
    }, []);
    return (
        <>
            <DeleteGenderForm />
        </>
    )
}

export default DeleteGenderPage