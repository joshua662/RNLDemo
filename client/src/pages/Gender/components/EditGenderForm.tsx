import BackButton from "../../../components/Button/BackButton";
import SubmitButton from "../../../components/Button/SubmitButton"
import FloatingLabelInput from "../../../components/Input/FloatingLabelInput"

const EditGenderForm = () => {
    return (
        <>
            <form>
                <div className="mb-4">
                    <FloatingLabelInput label="Gender" type="text" name="gender" />
                </div>
                <div className="flex justify-end gap-2">
                    <BackButton label="Back" path="/" />
                    <SubmitButton label="Save Gender" />
                </div>
            </form>
        </>
    );
};

export default EditGenderForm;