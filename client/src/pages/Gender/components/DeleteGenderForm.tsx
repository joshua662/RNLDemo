import { useEffect, useState, type FormEvent } from "react";
import BackButton from "../../../components/Button/BackButton";
import SubmitButton from "../../../components/Button/SubmitButton";
import FloatingLabelInput from "../../../components/Input/FloatingLabelInput";
import GenderService from "../../../services/GenderService";
import Spinner from "../../../components/Spinner/Spinner";
import { useNavigate, useParams } from "react-router-dom";

const DeleteGenderForm = () => {
    const [loadingGet, setLoadingGet] = useState(false);
    const [loadingDestroy, setLoadingDestroy] = useState(false);
    const [gender, setGender] = useState("");
    const [loadFinished, setLoadFinished] = useState(false);

    const { gender_id } = useParams();
    const navigate = useNavigate();

    const handleGender = async (genderId: string | number) => {
        try {
            setLoadingGet(true);

            const res = await GenderService.getGender(genderId);

            if (res.status === 200) {
                const existingGender = res.data?.gender?.gender;
                if (typeof existingGender === "string") {
                    setGender(existingGender);
                }
            } else {
                console.error(
                    "Unexpected error status occured during getting gender:",
                    res.status,
                );
            }
        } catch (error) {
            console.error(
                "Unexpected server error occured during getting gender: ",
                error,
            );
        } finally {
            setLoadingGet(false);
            setLoadFinished(true);
        }
    };

    const handleDestroyGender = async (e: FormEvent) => {
        e.preventDefault();
        if (!gender_id) return;

        try {
            setLoadingDestroy(true);

            const res = await GenderService.destroyGender(gender_id);

            if (res.status >= 200 && res.status < 300) {
                navigate("/genders", { state: { message: res.data.message } });
            } else {
                console.error(
                    "Unexpected status error occured during deleting gender: ",
                    res.status,
                );
            }
        } catch (error) {
            console.error(
                "Unexpected server error occured during deleting gender: ",
                error,
            );
        } finally {
            setLoadingDestroy(false);
        }
    };

    useEffect(() => {
        if (gender_id) {
            const parsedGenderId = Number(gender_id);
            if (Number.isNaN(parsedGenderId)) {
                console.error(
                    "Unexpected error occured during getting gender: invalid gender id",
                    gender_id,
                );
                setLoadFinished(true);
                return;
            }
            handleGender(parsedGenderId);
        } else {
            console.error(
                "Unexpected error occured during getting gender: ",
                gender_id,
            );
            setLoadFinished(true);
        }
    }, [gender_id]);

    return (
        <>
            {loadingGet ? (
                <div className="flex justify-center items-center mt-52">
                    <Spinner size="lg" />
                </div>
            ) : gender ? (
                <form onSubmit={handleDestroyGender}>
                    <div className="mb-4">
                        <FloatingLabelInput
                            label="Gender"
                            type="text"
                            name="gender"
                            value={gender}
                            readOnly={true}
                            inputClassName="bg-gray-50 cursor-default"
                        />
                    </div>
                    <div className="flex justify-end gap-2">
                        {!loadingDestroy && (
                            <BackButton label="Back" path="/genders" />
                        )}
                        <SubmitButton
                            label="Delete Gender"
                            className="bg-red-600 hover:bg-red-700"
                            loading={loadingDestroy}
                            loadingLabel="Deleting Gender..."
                        />
                    </div>
                </form>
            ) : loadFinished ? (
                <p className="mt-8 text-center text-sm text-gray-600">
                    Gender not found or could not be loaded.
                </p>
            ) : (
                <div className="flex justify-center items-center mt-52">
                    <Spinner size="lg" />
                </div>
            )}
        </>
    );
};

export default DeleteGenderForm;
