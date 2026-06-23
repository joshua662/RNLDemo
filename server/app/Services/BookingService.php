<?php

namespace App\Services;

use App\Enums\BookingStatus;
use App\Events\BookingCreated;
use App\Events\BookingStatusChanged;
use App\Models\Booking;
use App\Models\Payment;
use App\Repositories\BookingRepository;

class BookingService
{
    public function __construct(
        protected BookingRepository $repository,
        protected BookingNotificationService $notificationService
    ) {}

    public function createBooking(array $data, ?int $userId = null): Booking
    {
        $weight = (float) ($data['weight'] ?? 8);
        $totalPrice = Booking::calculatePrice($weight);

        $booking = $this->repository->create([
            'user_id' => $userId,
            'booking_number' => Booking::generateBookingNumber(),
            'full_name' => $data['full_name'],
            'phone' => $data['phone'],
            'email' => $data['email'] ?? null,
            'customer_type' => $data['customer_type'] ?? 'walk_in',
            'address' => $data['address'],
            'pickup_date' => $data['pickup_date'] ?? null,
            'pickup_time' => $data['pickup_time'] ?? null,
            'weight' => $weight,
            'notes' => $data['notes'] ?? null,
            'status' => BookingStatus::Pending->value,
            'tracking_code' => Booking::generateTrackingCode(),
            'total_price' => $totalPrice,
            'payment_method' => 'cash',
            'latitude' => $data['latitude'] ?? null,
            'longitude' => $data['longitude'] ?? null,
            'is_done' => false,
        ]);

        Payment::create([
            'booking_id' => $booking->id,
            'amount' => $totalPrice,
            'payment_method' => 'cash',
            'payment_status' => 'pending',
        ]);

        $booking = $booking->load('payment', 'user');
        event(new BookingCreated($booking));

        return $booking;
    }

    public function updateBooking(Booking $booking, array $data, bool $asAdmin = false): Booking
    {
        if ($booking->status === BookingStatus::Cancelled->value) {
            throw new \InvalidArgumentException('Cancelled bookings cannot be edited.');
        }

        $scheduleOnly = $this->isScheduleOnlyUpdate($data);

        if (! $booking->canEdit() && ! ($asAdmin && $scheduleOnly)) {
            throw new \InvalidArgumentException('Booking can no longer be edited.');
        }

        if (array_key_exists('pickup_time', $data)) {
            $data['pickup_time'] = Booking::normalizePickupTime($data['pickup_time']);
        }

        $weight = (float) ($data['weight'] ?? $booking->weight);
        $previousStatus = $booking->status;
        $previousPickupDate = $booking->pickup_date?->format('Y-m-d');
        $previousPickupTime = Booking::normalizePickupTime($booking->pickup_time);
        $updates = [
            'full_name' => $data['full_name'] ?? $booking->full_name,
            'phone' => $data['phone'] ?? $booking->phone,
            'customer_type' => $data['customer_type'] ?? $booking->customer_type,
            'address' => $data['address'] ?? $booking->address,
            'pickup_date' => array_key_exists('pickup_date', $data) ? $data['pickup_date'] : $booking->pickup_date,
            'pickup_time' => array_key_exists('pickup_time', $data) ? $data['pickup_time'] : $booking->pickup_time,
            'weight' => $weight,
            'notes' => $data['notes'] ?? $booking->notes,
            'payment_method' => 'cash',
            'latitude' => $data['latitude'] ?? $booking->latitude,
            'longitude' => $data['longitude'] ?? $booking->longitude,
            'total_price' => Booking::calculatePrice($weight),
        ];

        $scheduleChanged =
            ($previousPickupDate !== ($updates['pickup_date'] instanceof \DateTimeInterface ? $updates['pickup_date']->format('Y-m-d') : $updates['pickup_date'])) ||
            ($previousPickupTime !== $updates['pickup_time']);

        if (
            $scheduleChanged &&
            $updates['pickup_date'] &&
            $updates['pickup_time'] &&
            in_array($previousStatus, [
                BookingStatus::Pending->value,
                BookingStatus::Confirmed->value,
                BookingStatus::PickupScheduled->value,
            ], true)
        ) {
            $updates['status'] = BookingStatus::PickupScheduled->value;
        }

        $updated = $this->repository->update($booking, $updates);

        if ($scheduleChanged && $updated->pickup_date && $updated->pickup_time) {
            $date = $updated->pickup_date->format('Y-m-d');
            event(new BookingStatusChanged(
                $updated,
                $previousStatus,
                "Pickup scheduled for {$date} at {$updated->pickup_time}."
            ));
        }

        return $updated;
    }

    private function isScheduleOnlyUpdate(array $data): bool
    {
        $keys = array_keys($data);

        return $keys !== [] && empty(array_diff($keys, ['pickup_date', 'pickup_time']));
    }

    public function updateStatus(Booking $booking, string $status, ?string $deliveryRider = null): Booking
    {
        $previous = $booking->status;
        $updates = ['status' => $status];
        if ($deliveryRider !== null) {
            $updates['delivery_rider'] = $deliveryRider;
        }
        if ($status === BookingStatus::Done->value) {
            $status = BookingStatus::Delivered->value;
            $updates['status'] = $status;
            $updates['is_done'] = true;
        }

        $updated = $this->repository->update($booking, $updates);

        if ($status === BookingStatus::Delivered->value) {
            $this->markPaymentReceived($updated);
        }

        $statusEnum = BookingStatus::tryFrom($status);
        $message = $statusEnum?->notificationMessage() ?? "Status updated to {$status}";

        event(new BookingStatusChanged($updated->fresh(['payment', 'user']), $previous, $message));

        return $updated;
    }

    public function markDone(Booking $booking, bool $done = true): Booking
    {
        $previous = $booking->status;

        if ($done) {
            $updated = $this->repository->update($booking, [
                'is_done' => true,
                'status' => BookingStatus::Delivered->value,
            ]);
            $this->markPaymentReceived($updated);
            $message = BookingStatus::Delivered->notificationMessage();
            event(new BookingStatusChanged($updated->fresh(['payment', 'user']), $previous, $message));

            return $updated;
        }

        $updated = $this->repository->update($booking, ['is_done' => false]);
        $message = 'Your order has been marked as not done yet. We will continue processing.';
        event(new BookingStatusChanged($updated, $previous, $message));

        return $updated;
    }

    protected function markPaymentReceived(Booking $booking): void
    {
        $payment = $booking->payment ?? $booking->payment()->first();
        if ($payment && $payment->payment_status !== 'paid') {
            $payment->update(['payment_status' => 'paid']);
        }
    }

    public function adminCancelBooking(Booking $booking): Booking
    {
        if ($booking->isFinished()) {
            throw new \InvalidArgumentException('Cannot cancel a finished booking.');
        }

        $previous = $booking->status;
        $updated = $this->repository->update($booking, [
            'status' => BookingStatus::Cancelled->value,
            'is_done' => false,
        ]);
        $this->notificationService->notifyCancelled($updated, $previous);

        return $updated;
    }

    public function cancelBooking(Booking $booking): Booking
    {
        if (! $booking->canCancel()) {
            throw new \InvalidArgumentException('Booking cannot be cancelled at this stage.');
        }

        return $this->updateStatus($booking, BookingStatus::Cancelled->value);
    }

    public function deleteBooking(Booking $booking): void
    {
        $booking->payment()?->delete();
        if ($booking->trashed()) {
            $booking->forceDelete();
        } else {
            $booking->delete();
        }
    }

    public function trashCancelledBooking(Booking $booking, int $userId): Booking
    {
        if ($booking->user_id !== $userId) {
            throw new \InvalidArgumentException('Unauthorized.');
        }

        if (! $booking->canDelete()) {
            throw new \InvalidArgumentException('Only cancelled bookings can be moved to trash.');
        }

        $booking->delete();

        return $booking;
    }

    public function restoreBooking(Booking $booking, int $userId): Booking
    {
        if ($booking->user_id !== $userId) {
            throw new \InvalidArgumentException('Unauthorized.');
        }

        if (! $booking->trashed()) {
            throw new \InvalidArgumentException('Booking is not in trash.');
        }

        $booking->restore();

        return $booking->fresh(['payment', 'user']);
    }

    public function forceDeleteBooking(Booking $booking, int $userId): void
    {
        if ($booking->user_id !== $userId) {
            throw new \InvalidArgumentException('Unauthorized.');
        }

        if (! $booking->trashed()) {
            throw new \InvalidArgumentException('Move booking to trash before permanent delete.');
        }

        $booking->payment()?->delete();
        $booking->forceDelete();
    }
}
