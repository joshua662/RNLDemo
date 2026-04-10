import { useEffect, useState, type FC } from "react";
import { Table, TableBody, TableCell, TableHeader, TableRow } from "../../../components/Table"
import GenderService from "../../../services/GenderService";
import Spinner from "../../../components/Spinner/Spinner";
import type { GenderColumns } from "../../../interfaces/GenderInterface";

interface GenderListProps {
  refreshKey: boolean
  onEditGender: (gender: GenderColumns) => void
  onDeleteGender: (gender: GenderColumns) => void
}

export const GenderList: FC<GenderListProps> = ({
  refreshKey,
  onEditGender,
  onDeleteGender,
}) => {
  const [loadingGenders, setLoadingGenders] = useState(false)
  const [genders, setGenders] = useState<GenderColumns[]>([])

  const handleLoadGenders = async () => {
    try {
      setLoadingGenders(true)

      const res = await GenderService.loadGenders()

      if (res.status === 200) {
        setGenders(res.data.genders)
      } else {
        console.error('Unexpected error status occured during loading genders:', res.status)
      }
    } catch (error) {
      console.error('Unexpected server eror occured during loading genders: ', error)
    } finally {
      setLoadingGenders(false);
    }
  };

  useEffect(() => {
    handleLoadGenders()
  }, [refreshKey]);

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
                <TableCell isHeader className="px-5 py-3 font-medium text-center">
                  Action
                </TableCell>
              </TableRow>
            </TableHeader>
            <TableBody className="divide-y divide-gray-100 text-gray-500 text-sm">
              {loadingGenders ? (
                <TableRow>
                  <TableCell colSpan={2} className="px-4 py-3 text-center">
                    <Spinner size="md" />
                  </TableCell>
                </TableRow>
              ) : (
                genders.map((gender: GenderColumns, index: number) => (
                  <TableRow className="hover:bg-gray-100" key={gender.gender_id}>
                    <TableCell className="px-4 py-3 text-center">{index + 1}</TableCell>
                    <TableCell className="px-4 py-3 text-start">{gender.gender}</TableCell>
                    <TableCell className="px-4 px-y text-center">
                      <div className="flex justfy-center items-center gap-x-4">
                        <button
                          type="button"
                          className="cursor-pointer font-medium text-green-600 hover:underline"
                          onClick={() => onEditGender(gender)}
                        >
                          Edit
                        </button>
                        <button
                          type="button"
                          className="cursor-pointer font-medium text-red-600 hover:underline"
                          onClick={() => onDeleteGender(gender)}
                        >
                          Delete
                        </button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
      </div>
    </>
  );
};