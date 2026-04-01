<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\GenderController;

Route::controller(GenderController::class)->prefix('/gender')->group(function () {
    Route::post('/storeGender', 'storeGender');
});
// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');
