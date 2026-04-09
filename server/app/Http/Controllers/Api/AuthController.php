<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $validated = $request->validate([
            'username' => ['required', 'string', 'min:6', 'max:12'],
            'password' => ['required', 'string', 'min:6', 'max:12'],
        ]);

        $user = User::with(['gender'])
            ->where('username', $validated['username'])
            ->where('is_deleted', false)
            ->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'message' => 'The provided credentials are incorrect.',
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 200);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged Out Successfully',
        ], 200);
    }

    public function me(Request $request)
    {
        return response()->json([
            'user' => $request->user()->load(['gender']),
        ], 200);
    }
}
