<?php

namespace App\Http\Resources;

use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BookingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'booking_number' => $this->booking_reference,
            'booking_reference' => $this->booking_reference,
            'full_name' => $this->full_name,
            'phone' => $this->phone,
            'email' => $this->email,
            'customer_type' => $this->customer_type ?? 'walk_in',
            'address' => $this->address,
            'pickup_date' => $this->pickup_date?->format('Y-m-d'),
            'pickup_time' => Booking::normalizePickupTime($this->pickup_time),
            'weight' => (float) $this->weight,
            'notes' => $this->notes,
            'status' => $this->status,
            'tracking_code' => $this->tracking_code,
            'total_price' => (float) $this->total_price,
            'is_done' => (bool) $this->is_done,
            'is_finished' => $this->isFinished(),
            'delivery_rider' => $this->delivery_rider,
            'payment_method' => $this->payment_method,
            'latitude' => $this->latitude ? (float) $this->latitude : null,
            'longitude' => $this->longitude ? (float) $this->longitude : null,
            'can_edit' => $this->canEdit(),
            'can_cancel' => $this->canCancel(),
            'can_delete' => $this->canDelete(),
            'payment' => $this->whenLoaded('payment', fn () => new PaymentResource($this->payment)),
            'user' => $this->whenLoaded('user', fn () => new UserResource($this->user)),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
