<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\GenderController;
use App\Http\Controllers\Api\UserController;

Route::controller(GenderController::class)->prefix('/gender')->group(function () {
    Route::get('/loadGenders', 'loadGenders'); //gender/loadGenders
    Route::get('/getGender/{genderID}', 'getGender'); //gender/getGender/{genderID}
    Route::post('/storeGender', 'storeGender'); //gender/storeGender
    Route::put('/updateGender/{gender}', 'updateGender'); //gender/updateGender/{genderId}
    Route::put('/destroyGender/{gender}', 'destroyGender');
});

Route::controller(UserController::class)->prefix('/user')->group(function () {
    Route::get('/loadUsers', 'loadUsers');
    Route::post('/storeUser', 'storeUser');
    Route::put('/updateUser/{user}', 'updateUser');
});

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');
