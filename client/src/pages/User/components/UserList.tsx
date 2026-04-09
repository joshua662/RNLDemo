import { useCallback, useEffect, useRef, useState, type FC } from "react";
import { Table, TableBody, TableCell, TableHeader, TableRow } from "../../../components/Table"
import Spinner from "../../../components/Spinner/Spinner";
import UserService from "../../../services/UserService";
import type { UserColumns } from "../../../interfaces/UserInterface";
import FloatingLabelInput from "../../../components/Input/FloatingLabelInput";

interface UserListProps {
    onAddUser: () => void;
    onEditUser: (user: UserColumns | null) => void;
    onDeleteUser: (user: UserColumns | null) => void;
    refreshKey: boolean;
}

const UserList: FC<UserListProps> = ({ onAddUser, onEditUser, onDeleteUser, refreshKey }) => {
    const [loadingUsers, setLoadingUsers] = useState(false);
    const [users, setUsers] = useState<UserColumns[]>([]);

    const tableRef = useRef<HTMLDivElement>(null);
    const loadingUsersRef = useRef(false);
    const sentinelRef = useRef<HTMLTableRowElement | null>(null);

    const currentPageRef = useRef(1);
    const lastPageRef = useRef(1);
    const hasMoreRef = useRef(true);

    const [search, setSearch] = useState("");
    const [debouncedSearch, setDebouncedSearch] = useState("");

    const handleLoadUsers = useCallback(async (page: number, append = false) => {
        try {
            if (loadingUsersRef.current) return;
            if (page < 1) return;
            if (lastPageRef.current && page > lastPageRef.current) return;

            loadingUsersRef.current = true;
            setLoadingUsers(true);

            const res = await UserService.loadUsers(page, debouncedSearch);

            if (res.status === 200) {
                const usersData = res.data.users.data || res.data.users || [];
                const lastPage = res.data.users.last_page || res.data.last_page || 1;

                setUsers(prev => (append ? [...prev, ...usersData] : usersData));

                currentPageRef.current = page;
                lastPageRef.current = lastPage;
                hasMoreRef.current = page < lastPage;
            } else {
                setUsers(prev => (append ? prev : []));
                hasMoreRef.current = false;
            }
        } catch (error) {
            console.error('Unexpected server error occured during loading users: ', error);
        } finally {
            loadingUsersRef.current = false;
            setLoadingUsers(false);
        }
    }, [debouncedSearch]);

    const handleUserFullNameFormat = (user: UserColumns) => {
        let fullName = '';

        if (user.middle_name) {
            fullName = `${user.last_name}, ${user.first_name} ${user.middle_name.charAt(0)}.`;
        } else {
            fullName = `${user.last_name}, ${user.first_name}`;
        }

        if (user.suffix_name) {
            fullName += ` ${user.suffix_name}`;
        }

        return fullName;
    };

    // Infinite scroll observer
    useEffect(() => {
        const root = tableRef.current;
        const target = sentinelRef.current;
        if (!root || !target) return;

        const observer = new IntersectionObserver(
            (entries) => {
                const entry = entries[0];
                if (!entry?.isIntersecting) return;
                if (!hasMoreRef.current) return;
                if (loadingUsersRef.current) return;

                const nextPage = currentPageRef.current + 1;
                handleLoadUsers(nextPage, true);
            },
            {
                root,
                rootMargin: "200px 0px",
                threshold: 0.01,
            }
        );

        observer.observe(target);
        return () => observer.disconnect();
    }, [handleLoadUsers]);

    // Debounce search input
    useEffect(() => {
        const timer = setTimeout(() => {
            setDebouncedSearch(search);
        }, 800);

        return () => clearTimeout(timer);
    }, [search]);

    // Reset and reload when search or refreshKey changes
    useEffect(() => {
        setUsers([]);
        currentPageRef.current = 1;
        lastPageRef.current = 1;
        hasMoreRef.current = true;
        handleLoadUsers(1, false);
    }, [handleLoadUsers, refreshKey, debouncedSearch]);

    return (
        <>
            <div className="overflow-hidden rounded-lg border border-gray-200 bg-white">
                <div ref={tableRef} className="relative max-w-full max-h-[calc(100vh-8.5rem)] overflow-y-auto overflow-x-auto">
                    <Table>
                        <caption className="mb-4">
                            <div className="border-b border-gray-100">
                                <div className="p-4 flex justify-between">
                                    <div className="w-64">
                                        <FloatingLabelInput
                                            label="Search"
                                            type="text"
                                            name="search"
                                            value={search}
                                            onChange={(e) => setSearch(e.target.value)}
                                            autoFocus
                                        />
                                    </div>
                                    <button
                                        type="button"
                                        className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg shadow-lg transition cursor-pointer"
                                        onClick={onAddUser}
                                    >
                                        Add User
                                    </button>
                                </div>
                            </div>
                        </caption>
                        <TableHeader className="border-b border-gray-200 bg-blue-600 sticky top-0 text-white text-xs">
                            <TableRow>
                                <TableCell isHeader className="px-5 py-3 font-medium text-center">No.</TableCell>
                                <TableCell isHeader className="px-5 py-3 font-medium text-start">Full Name</TableCell>
                                <TableCell isHeader className="px-5 py-3 font-medium text-start">Gender</TableCell>
                                <TableCell isHeader className="px-5 py-3 font-medium text-start">Birth Date</TableCell>
                                <TableCell isHeader className="px-5 py-3 font-medium text-start">Age</TableCell>
                                <TableCell isHeader className="px-5 py-3 font-medium text-center">Action</TableCell>
                            </TableRow>
                        </TableHeader>
                        <TableBody className="divide-y divide-gray-100 text-gray-500 text-sm">
                            {users.length > 0 ? (
                                users.map((user, index) => (
                                    <TableRow className="hover:bg-gray-100" key={index}>
                                        <TableCell className="px-4 py-3 text-center">
                                            {index + 1}
                                        </TableCell>
                                        <TableCell className="px-4 py-3 text-start">
                                            {handleUserFullNameFormat(user)}
                                        </TableCell>
                                        <TableCell className="px-4 py-3 text-start">
                                            {user.gender.gender}
                                        </TableCell>
                                        <TableCell className="px-4 py-3 text-start">
                                            {user.birth_date}
                                        </TableCell>
                                        <TableCell className="px-4 py-3 text-start">
                                            {user.age}
                                        </TableCell>
                                        <TableCell className="px-4 py-3 text-center">
                                            <div className="flex justify-center gap-4">
                                                <button type="button" className="text-green-600 hover:underline" onClick={() => onEditUser(user)}>Edit</button>
                                                <button type="button" className="text-red-600 hover:underline" onClick={() => onDeleteUser(user)}>Delete</button>
                                            </div>
                                        </TableCell>
                                    </TableRow>
                                ))
                            ) : loadingUsers ? (
                                <TableRow>
                                    <TableCell colSpan={6} className="px-4 py-3 text-center">
                                        <Spinner size="md" />
                                    </TableCell>
                                </TableRow>
                            ) : (
                                <TableRow>
                                    <TableCell colSpan={6} className="px-4 py-3 text-center font-medium">
                                        No Records Found
                                    </TableCell>
                                </TableRow>
                            )}
                            {loadingUsers && users.length > 0 && (
                                <TableRow>
                                    <TableCell colSpan={6} className="px-4 py-3 text-center">
                                        <Spinner size="md" />
                                    </TableCell>
                                </TableRow>
                            )}
                            <tr ref={sentinelRef}>
                                <td colSpan={6} className="px-0 py-0">
                                    <div style={{ height: 1 }} />
                                </td>
                            </tr>
                        </TableBody>
                    </Table>
                </div>
            </div>
        </>
    );
}

export default UserList;
