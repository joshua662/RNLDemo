import { Link } from "react-router-dom"
import { Table, TableBody, TableCell, TableHeader, TableRow } from "../../../components/Table"

export const GenderList = () => {
    const genders = [
        {
            gender_id: 1,
            gender: "Male",
            action: (
                <>
                    <div className="flex gap-4">
                        <div>
                            <Link
                                to="/gender/edit"
                                className="text-green-600 hover:underline font-medium">
                                Edit
                            </Link>
                        </div>
                        <div>
                            <Link to="/gender/delete" className="text-red-600 hover:underline font-medium">
                                Delete
                            </Link>
                        </div>
                    </div>
                </>
            ),
        },
        {
            gender_id: 2,
            gender: "Female",
            action: (
                <>
                    <div className="flex gap-4">
                        <div>
                            <Link
                                to="/gender/edit"
                                className="text-green-600 hover:underline font-medium">
                                Edit
                            </Link>
                        </div>
                        <div>
                            <Link to="/gender/delete" className="text-red-600 hover:underline font-medium">
                                Delete
                            </Link>
                        </div>
                    </div>
                </>
            ),
        },
        {
            gender_id: 3,
            gender: "Prefer Not to Say",
            action: (
                <>
                    <div className="flex gap-4">
                        <div>
                            <Link
                                to="/gender/edit"
                                className="text-green-600 hover:underline font-medium">
                                Edit
                            </Link>
                        </div>
                        <div>
                            <Link to="/gender/delete" className="text-red-600 hover:underline font-medium">
                                Delete
                            </Link>
                        </div>
                    </div>
                </>
            ),
        },
    ]
    return (
        <>
            <div className="overflow-hidden rounded-lg border border-gray-200 bg-white">
                <div className="max-w-full max-h-[calc(100vh)] overflow-x-auto">
                    <Table>
                        <TableHeader className="border-b border-gray-200 bg-blue-600 sticky top-o text-white text-xs">
                            <TableRow>
                                <TableCell isHeader className="px-5 py-3 font-medium text-center">
                                    No.
                                </TableCell>
                                <TableCell isHeader className="px-5 py-3 font-medium text-center">
                                    Gender
                                </TableCell>
                                {/* <TableCell isHeader className="px-5 py-3 font-medium text-center">
                                    Action
                                </TableCell> */}
                            </TableRow>
                        </TableHeader>
                        <TableBody className="divide-y divide-gray-100 text-gray-500 text-sm">
                            {genders.map((gender, index) => (
                                <TableRow className="hover:bg-gray-100" key={index}>
                                    <TableCell className="px-4 py-3 text-center">
                                        {gender.gender_id}
                                    </TableCell>
                                    <TableCell className="px-4 py-3 text-start">
                                        {gender.gender}
                                    </TableCell>
                                    <TableCell className="px-4 py-3 text-start">
                                        {gender.action}
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </div>
            </div>
        </>
    );
};
