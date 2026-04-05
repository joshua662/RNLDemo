import { useEffect, useState, type FC, type FormEvent } from "react";
import BackButton from "../../../components/Button/BackButton";
import SubmitButton from "../../../components/Button/SubmitButton"
import FloatingLabelInput from "../../../components/Input/FloatingLabelInput"
import GenderService from "../../../services/GenderService";
import { useParams } from "react-router-dom";
import Spinner from "../../../components/Spinner/Spinner";
import axios from "axios";
import type { GenderFieldErrors } from "../../../interfaces/GenderInterface";

interface EditGenderFromProps {
    onGenderUpdated: (message: string) => void
}

const EditGenderForm: FC<EditGenderFromProps> = ({ onGenderUpdated }) => {
    const [loadingGet, setLoadingGet] = useState(false);
    const [loadingUpdate, setLoadingUpdate] = useState(false);
    const [gender, setGender] = useState("");
    const [initialGender, setInitialGender] = useState("");
    const [errors, setErrors] = useState<GenderFieldErrors>({});

    const { gender_id } = useParams();

    const handleGender = async (genderId: string | number) => {
        try {
            setLoadingGet(true)

            const res = await GenderService.getGender(genderId)

            if (res.status === 200) {
                const existingGender = res.data?.gender?.gender
                if (typeof existingGender === "string") {
                    setGender(existingGender)
                    setInitialGender(existingGender)
                }
            } else {
                console.error('Unexpected error status occured during getting gender:', res.status)
            }
        } catch (error) {
            console.error('Unexpected server error occured during getting gender: ', error)
        } finally {
            setLoadingGet(false)
        }
    };

    const handleUpdateGender = async (e: FormEvent) => {
        try {
            e.preventDefault()
            const trimmedGender = gender.trim()

            setErrors({})
            if (!trimmedGender) {
                setLoadingUpdate(true)
                setErrors({
                    gender: ["The gender field is required."]
                })
                window.setTimeout(() => {
                    setLoadingUpdate(false)
                }, 250)
                return
            }
            if (trimmedGender === initialGender.trim()) {
                setErrors({})
                setLoadingUpdate(false)
                onGenderUpdated("No changes were made.")
                return
            }

            setLoadingUpdate(true)

            const res = await GenderService.updateGender(gender_id!, { gender: trimmedGender })

            if (res.status >= 200 && res.status < 300) {
                setErrors({})
                const updatedGender = res.data?.gender?.gender
                if (typeof updatedGender === "string" && updatedGender.length > 0) {
                    setGender(updatedGender)
                    setInitialGender(updatedGender)
                } else {
                    setGender(trimmedGender)
                    setInitialGender(trimmedGender)
                }
                onGenderUpdated(
                    typeof res.data?.message === "string"
                        ? res.data.message
                        : "Gender updated successfully.",
                )
            } else {
                console.error('Unexpected status error occured during updating gender: ')
            }
            setLoadingUpdate(false)
        } catch (error: unknown) {
            if (axios.isAxiosError(error) && error.response?.status === 422) {
                setErrors(error.response.data.errors)
            } else {
                console.error('Unexpected server error occured during updating gender: ', error)
            }
            setLoadingUpdate(false);
        }
    }

    useEffect(() => {
        if (gender_id) {
            const parsedGenderId = Number(gender_id)
            if (Number.isNaN(parsedGenderId)) {
                console.error('Unexpected error occured during getting gender: invalid gender id', gender_id)
                return
            }
            handleGender(parsedGenderId)
        } else {
            console.error('Unexpected error occured during getting gender: ', gender_id)
        }
    }, [gender_id]);


    return (
        <>
            {loadingGet && !gender ? (
                <div className="flex justify-center items-center mt-52">
                    <Spinner size="lg" />
                </div>
            ) : (
                <form onSubmit={handleUpdateGender} noValidate>
                    <div className="mb-4">
                        <FloatingLabelInput
                            label="Gender"
                            type="text"
                            name="gender"
                            value={gender}
                            onChange={(e) => {
                                const nextValue = e.target.value
                                setGender(nextValue)
                                if (nextValue.trim()) {
                                    setErrors({})
                                }
                            }}
                            errors={errors.gender}
                            required
                            autoFocus
                        />
                    </div>
                    <div className="flex justify-end gap-2">
                        {!loadingUpdate &&
                            <BackButton label="Back" path="/" />
                        }
                        <SubmitButton label="Update Gender" loading={loadingUpdate} loadingLabel="Updating Gender..." />
                    </div>
                </form>
            )}
        </>
    );
};

export default EditGenderForm;