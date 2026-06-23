<?php

use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\SmsLogController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\TestimonialController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/auth/reset-password', [AuthController::class, 'resetPassword']);

Route::get('/services', [ServiceController::class, 'index']);
Route::get('/testimonials', [TestimonialController::class, 'index']);
Route::post('/bookings/track', [BookingController::class, 'track']);

// Authenticated routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Customer booking management
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::get('/my-orders', [BookingController::class, 'myOrders']);
    Route::get('/bookings/{id}', [BookingController::class, 'show']);
    Route::put('/bookings/{id}', [BookingController::class, 'update']);
    Route::post('/bookings/{id}/cancel', [BookingController::class, 'cancel']);
    Route::post('/bookings/{id}/trash', [BookingController::class, 'trash']);
    Route::get('/my-orders/trash', [BookingController::class, 'myTrash']);
    Route::post('/bookings/{id}/restore', [BookingController::class, 'restore']);
    Route::delete('/bookings/{id}/force', [BookingController::class, 'forceDestroy']);
    Route::get('/sms-logs', [SmsLogController::class, 'myLogs']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllRead']);
    Route::delete('/notifications', [NotificationController::class, 'clearAll']);

    // Admin routes
    Route::middleware('admin')->prefix('admin')->group(function () {
        Route::get('/dashboard', [AdminController::class, 'dashboard']);
        Route::get('/customers', [AdminController::class, 'customers']);
        Route::post('/customers', [AdminController::class, 'storeCustomer']);
        Route::put('/customers/{customer}', [AdminController::class, 'updateCustomer']);
        Route::delete('/customers/{customer}', [AdminController::class, 'destroyCustomer']);
        Route::get('/reports', [AdminController::class, 'reports']);

        Route::get('/bookings', [BookingController::class, 'index']);
        Route::post('/bookings', [BookingController::class, 'adminStore']);
        Route::post('/bookings/batch-restore', [BookingController::class, 'adminBatchRestore']);
        Route::post('/bookings/batch-delete-permanent', [BookingController::class, 'adminBatchDeletePermanent']);
        Route::get('/bookings/{id}', [BookingController::class, 'adminShow']);
        Route::patch('/bookings/{id}/status', [BookingController::class, 'updateStatus']);
        Route::patch('/bookings/{id}/done', [BookingController::class, 'markDone']);
        Route::patch('/bookings/{id}/not-done', [BookingController::class, 'markNotDone']);
        Route::post('/bookings/{id}/cancel', [BookingController::class, 'adminCancel']);
        Route::put('/bookings/{id}', [BookingController::class, 'update']);
        Route::delete('/bookings/{id}', [BookingController::class, 'destroy']);
        Route::get('/bookings/{id}/export', [BookingController::class, 'exportPdf']);
        Route::post('/bookings/{id}/admin-trash', [BookingController::class, 'adminTrash']);
        Route::get('/bookings-trashed', [BookingController::class, 'adminTrashedList']);
        Route::post('/bookings/{id}/admin-restore', [BookingController::class, 'adminRestore']);

        Route::get('/services', [ServiceController::class, 'adminIndex']);
        Route::post('/services', [ServiceController::class, 'store']);
        Route::put('/services/{service}', [ServiceController::class, 'update']);
        Route::delete('/services/{service}', [ServiceController::class, 'destroy']);

        Route::get('/payments', [PaymentController::class, 'index']);
        Route::patch('/payments/{payment}', [PaymentController::class, 'update']);
    });
});
