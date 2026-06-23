<?php

namespace App\Models;

use App\Enums\BookingStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Booking extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'user_id',
        'booking_number',
        'full_name',
        'phone',
        'email',
        'customer_type',
        'address',
        'pickup_date',
        'pickup_time',
        'weight',
        'notes',
        'status',
        'tracking_code',
        'total_price',
        'is_done',
        'delivery_rider',
        'latitude',
        'longitude',
        'payment_method',
    ];

    protected function casts(): array
    {
        return [
            'pickup_date' => 'date',
            'weight' => 'decimal:2',
            'total_price' => 'decimal:2',
            'is_done' => 'boolean',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function payment(): HasOne
    {
        return $this->hasOne(Payment::class);
    }

    public function notifications(): HasMany
    {
        return $this->hasMany(UserNotification::class);
    }

    public function smsLogs(): HasMany
    {
        return $this->hasMany(SmsLog::class);
    }

    public function isFinished(): bool
    {
        return $this->is_done || in_array($this->status, BookingStatus::finished(), true);
    }

    public function canEdit(): bool
    {
        return ! $this->isFinished() && $this->status !== BookingStatus::Cancelled->value;
    }

    public static function normalizePickupTime(?string $time): ?string
    {
        if ($time === null || $time === '') {
            return null;
        }

        if (preg_match('/^(\d{1,2}):(\d{2})/', trim($time), $matches)) {
            return sprintf('%02d:%02d', (int) $matches[1], (int) $matches[2]);
        }

        return $time;
    }

    public function canCancel(): bool
    {
        return ! $this->isFinished() && $this->status !== BookingStatus::Cancelled->value;
    }

    public function getBookingReferenceAttribute(): string
    {
        return $this->booking_number
            ?? $this->tracking_code
            ?? 'ORDER-'.$this->id;
    }

    public static function generateTrackingCode(): string
    {
        do {
            $code = strtoupper(substr(bin2hex(random_bytes(4)), 0, 8));
        } while (self::withTrashed()->where('tracking_code', $code)->exists());

        return $code;
    }

    public static function generateBookingNumber(): string
    {
        $year = date('Y');
        $prefix = "MDV-{$year}-";

        // Include soft-deleted rows — booking_number stays unique in the database
        $maxSeq = self::withTrashed()
            ->where('booking_number', 'like', $prefix.'%')
            ->pluck('booking_number')
            ->map(fn (?string $number) => $number ? (int) substr($number, -4) : 0)
            ->max() ?? 0;

        do {
            $maxSeq++;
            $candidate = $prefix.str_pad((string) $maxSeq, 4, '0', STR_PAD_LEFT);
        } while (self::withTrashed()->where('booking_number', $candidate)->exists());

        return $candidate;
    }

    public function canDelete(): bool
    {
        return $this->status === BookingStatus::Cancelled->value;
    }

    public static function calculatePrice(float $weight): float
    {
        if ($weight <= 0) {
            return 0;
        }

        $baseWeight = 8;
        $basePrice = 99;
        $extraPerKg = 12;

        if ($weight <= $baseWeight) {
            return $basePrice;
        }

        return $basePrice + (($weight - $baseWeight) * $extraPerKg);
    }
}
