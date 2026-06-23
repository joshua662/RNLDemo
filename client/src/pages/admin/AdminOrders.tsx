import { useCallback, useEffect, useState } from "react";
import { Search, FileDown, Eye, CheckCircle, XCircle, Plus, Pencil, Trash2 } from "lucide-react";
import { jsPDF } from "jspdf";
import AdminService from "../../services/AdminService";
import type { Booking } from "../../interfaces/types";
import { formatPickupSchedule, STATUS_LABELS } from "../../utils/constants";
import { useToast } from "../../contexts/ToastContext";
import { getApiErrorMessage } from "../../utils/apiError";
import Skeleton from "../../components/ui/Skeleton";
import StatusBadge from "../../components/booking/StatusBadge";
import BookingCard from "../../components/booking/BookingCard";
import BookingModal from "../../components/booking/BookingModal";
import AdminBookingFormModal from "../../components/booking/AdminBookingFormModal";
import type { BookingStatus } from "../../interfaces/types";

const AdminOrders = () => {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [doneFilter, setDoneFilter] = useState("");
  const [page, setPage] = useState(1);
  const [lastPage, setLastPage] = useState(1);
  const [errorMessage, setErrorMessage] = useState("");
  const [selected, setSelected] = useState<Booking | null>(null);
  const [modalOpen, setModalOpen] = useState(false);
  const [formBooking, setFormBooking] = useState<Booking | null>(null);
  const [formOpen, setFormOpen] = useState(false);
  const [actionLoading, setActionLoading] = useState<number | null>(null);
  const [statusUpdatingId, setStatusUpdatingId] = useState<number | null>(null);
  const { showToast } = useToast();

  const load = useCallback(() => {
    setLoading(true);
    setErrorMessage("");

    const params: {
      search?: string;
      status?: string;
      page: number;
      is_done?: boolean;
    } = { page };

    const trimmedSearch = search.trim();
    if (trimmedSearch) params.search = trimmedSearch;
    if (statusFilter) params.status = statusFilter;
    if (doneFilter !== "") params.is_done = doneFilter === "true";

    AdminService.bookings(params)
      .then((res) => {
        const rows = Array.isArray(res.data.data) ? res.data.data : [];
        setBookings(rows);
        setLastPage(res.data.last_page || 1);
      })
      .catch((err) => {
        const message = getApiErrorMessage(err, "Failed to load bookings");
        setErrorMessage(message);
        showToast(message, "error");
      })
      .finally(() => setLoading(false));
  }, [doneFilter, page, search, showToast, statusFilter]);

  useEffect(() => {
    load();
  }, [load]);

  const exportPdf = (b: Booking) => {
    const doc = new jsPDF();
    doc.setFontSize(18);
    doc.text("MD & V Laundry Shop", 20, 20);
    doc.setFontSize(12);
    doc.text(`Booking: ${b.booking_number}`, 20, 35);
    doc.text(`Customer: ${b.full_name}`, 20, 45);
    doc.text(`Phone: ${b.phone}`, 20, 55);
    doc.text(`Status: ${STATUS_LABELS[b.status]}`, 20, 65);
    doc.text(`Pickup: ${formatPickupSchedule(b.pickup_date, b.pickup_time)}`, 20, 75);
    doc.text(`Total: PHP ${b.total_price}`, 20, 85);
    doc.text(`Tracking: ${b.tracking_code}`, 20, 95);
    doc.save(`${b.booking_number}.pdf`);
    showToast("PDF downloaded");
  };

  const openModal = (b: Booking) => {
    setSelected(b);
    setModalOpen(true);
  };

  const openEdit = (b: Booking) => {
    setFormBooking(b);
    setFormOpen(true);
  };

  const openCreate = () => {
    setFormBooking(null);
    setFormOpen(true);
  };

  const handleDelete = async (b: Booking) => {
    if (!confirm(`Permanently delete booking ${b.booking_number}?`)) return;
    setActionLoading(b.id);
    try {
      await AdminService.deleteBooking(b.id);
      showToast("Booking deleted");
      load();
    } catch (err) {
      showToast(getApiErrorMessage(err, "Failed to delete booking"), "error");
    } finally {
      setActionLoading(null);
    }
  };

  const handleFinish = async (b: Booking) => {
    if (!confirm(`Mark ${b.booking_number} as delivered? Payment will be recorded and customer notified.`)) return;
    setActionLoading(b.id);
    try {
      await AdminService.markDone(b.id);
      showToast("Marked as Delivered — payment recorded on dashboard");
      load();
    } catch {
      showToast("Failed to update booking", "error");
    } finally {
      setActionLoading(null);
    }
  };

  const handleCancel = async (b: Booking) => {
    if (!confirm(`Cancel ${b.booking_number}? Customer will be notified via SMS.`)) return;
    setActionLoading(b.id);
    try {
      await AdminService.cancelBooking(b.id);
      showToast("Booking cancelled — customer notified");
      load();
    } catch {
      showToast("Cannot cancel this booking", "error");
    } finally {
      setActionLoading(null);
    }
  };

  const isLocked = (b: Booking) =>
    b.is_finished || b.is_done || b.status === "done" || b.status === "delivered" || b.status === "cancelled";

  const handleStatusSelect = async (booking: Booking, status: BookingStatus) => {
    const label = STATUS_LABELS[status] || status;
    if (!confirm(`Set status to "${label}"? Customer will be notified.`)) return;
    setStatusUpdatingId(booking.id);
    try {
      if (status === "done") {
        await AdminService.markDone(booking.id);
        showToast("Marked as Delivered — payment recorded on dashboard");
      } else {
        await AdminService.updateBookingStatus(booking.id, status);
        showToast(`Status: ${label} — customer notified`);
      }
      load();
    } catch {
      showToast("Failed to update status", "error");
    } finally {
      setStatusUpdatingId(null);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <h2 className="text-2xl font-bold text-navy dark:text-white">Manage Bookings</h2>
        <button
          onClick={openCreate}
          className="flex items-center justify-center gap-2 px-4 py-2 bg-navy text-white rounded-xl text-sm font-medium"
        >
          <Plus className="w-4 h-4" /> Add Booking
        </button>
      </div>

      <div className="flex flex-col lg:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted" />
          <input
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            placeholder="Search bookings..."
            className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-border dark:border-slate-600 bg-white dark:bg-slate-800 outline-none focus:ring-2 focus:ring-sky"
          />
        </div>
        <select
          value={statusFilter}
          onChange={(e) => {
            setStatusFilter(e.target.value);
            setPage(1);
          }}
          className="px-4 py-2.5 rounded-xl border border-border dark:border-slate-600 bg-white dark:bg-slate-800"
        >
          <option value="">All Status</option>
          {Object.entries(STATUS_LABELS).map(([k, v]) => (
            <option key={k} value={k}>
              {v}
            </option>
          ))}
        </select>
        <select
          value={doneFilter}
          onChange={(e) => {
            setDoneFilter(e.target.value);
            setPage(1);
          }}
          className="px-4 py-2.5 rounded-xl border border-border dark:border-slate-600 bg-white dark:bg-slate-800"
        >
          <option value="">Done / Not Done</option>
          <option value="true">Done</option>
          <option value="false">Not Done</option>
        </select>
      </div>

      <div className="grid gap-4 lg:hidden">
        {loading ? (
          <Skeleton className="h-40" />
        ) : errorMessage ? (
          <div className="rounded-2xl border border-red-200 bg-red-50 p-5 text-center text-red-700 dark:border-red-900/60 dark:bg-red-950/30 dark:text-red-200">
            <p className="font-medium">{errorMessage}</p>
            <button onClick={load} className="mt-3 px-4 py-2 rounded-lg bg-red-600 text-white text-sm font-medium">
              Retry
            </button>
          </div>
        ) : (
          bookings.map((b) => (
            <BookingCard
              key={b.id}
              booking={b}
              showActions
              onEdit={!isLocked(b) ? () => openEdit(b) : undefined}
              onCancel={!isLocked(b) ? () => void handleCancel(b) : undefined}
              onDelete={() => void handleDelete(b)}
              onStatusSelect={!isLocked(b) ? (s) => void handleStatusSelect(b, s) : undefined}
              statusUpdating={statusUpdatingId === b.id}
            />
          ))
        )}
        {!loading && !errorMessage && !bookings.length && <p className="text-center text-muted py-8">No bookings found</p>}
      </div>

      <div className="hidden lg:block bg-white dark:bg-slate-800 rounded-2xl card-shadow border border-border dark:border-slate-700 overflow-x-auto">
        {loading ? (
          <div className="p-6">
            <Skeleton className="h-48" />
          </div>
        ) : errorMessage ? (
          <div className="p-8 text-center">
            <p className="text-red-600 dark:text-red-300 font-medium">{errorMessage}</p>
            <button onClick={load} className="mt-3 px-4 py-2 rounded-lg bg-navy text-white text-sm font-medium">
              Retry
            </button>
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 dark:bg-slate-900">
              <tr>
                {["Booking #", "Customer", "Pickup", "Status", "Actions"].map((h) => (
                  <th key={h} className="text-left px-4 py-3 font-semibold">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {bookings.map((b) => (
                <tr key={b.id} className="border-t border-border dark:border-slate-700 hover:bg-slate-50/50 dark:hover:bg-slate-700/30">
                  <td className="px-4 py-3 font-mono text-xs">
                    {b.booking_number}
                    <br />
                    <span className="text-muted">{b.tracking_code}</span>
                  </td>
                  <td className="px-4 py-3">
                    {b.full_name}
                    <br />
                    <span className="text-muted text-xs">{b.phone}</span>
                  </td>
                  <td className="px-4 py-3">{formatPickupSchedule(b.pickup_date, b.pickup_time)}</td>
                  <td className="px-4 py-3">
                    <StatusBadge status={b.status} done={b.is_done} />
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex flex-wrap gap-1">
                      <button
                        onClick={() => openModal(b)}
                        className="p-1.5 rounded-lg border hover:bg-slate-100 dark:hover:bg-slate-700"
                        title="View details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      {!isLocked(b) && (
                        <button
                          onClick={() => openEdit(b)}
                          className="p-1.5 rounded-lg border hover:bg-slate-100 dark:hover:bg-slate-700"
                          title="Edit"
                        >
                          <Pencil className="w-4 h-4" />
                        </button>
                      )}
                      <button
                        onClick={() => exportPdf(b)}
                        className="p-1.5 rounded-lg border hover:bg-slate-100 dark:hover:bg-slate-700"
                        title="Export PDF"
                      >
                        <FileDown className="w-4 h-4" />
                      </button>
                      {!isLocked(b) && (
                        <>
                          <button
                            onClick={() => void handleFinish(b)}
                            disabled={actionLoading === b.id}
                            className="px-2 py-1.5 rounded-lg bg-emerald-600 text-white text-xs font-medium flex items-center gap-1 hover:bg-emerald-700 disabled:opacity-60"
                            title="Finish"
                          >
                            <CheckCircle className="w-3.5 h-3.5" /> Finish
                          </button>
                          <button
                            onClick={() => void handleCancel(b)}
                            disabled={actionLoading === b.id}
                            className="px-2 py-1.5 rounded-lg bg-red-600 text-white text-xs font-medium flex items-center gap-1 hover:bg-red-700 disabled:opacity-60"
                            title="Cancel"
                          >
                            <XCircle className="w-3.5 h-3.5" /> Cancel
                          </button>
                        </>
                      )}
                      <button
                        onClick={() => void handleDelete(b)}
                        disabled={actionLoading === b.id}
                        className="p-1.5 rounded-lg border text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 disabled:opacity-60"
                        title="Delete"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        {!loading && !errorMessage && !bookings.length && <p className="p-8 text-center text-muted">No bookings found</p>}
      </div>

      {lastPage > 1 && (
        <div className="flex justify-center gap-2">
          <button disabled={page <= 1} onClick={() => setPage(page - 1)} className="px-4 py-2 rounded-lg border disabled:opacity-40">
            Prev
          </button>
          <span className="px-4 py-2">
            {page} / {lastPage}
          </span>
          <button disabled={page >= lastPage} onClick={() => setPage(page + 1)} className="px-4 py-2 rounded-lg border disabled:opacity-40">
            Next
          </button>
        </div>
      )}

      <BookingModal
        booking={selected}
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        onUpdated={(updated) => {
          if (updated) setSelected(updated);
          load();
        }}
      />
      <AdminBookingFormModal
        booking={formBooking}
        open={formOpen}
        onClose={() => setFormOpen(false)}
        onSaved={load}
      />
    </div>
  );
};

export default AdminOrders;
