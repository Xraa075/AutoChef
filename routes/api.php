<?php

use App\Http\Controllers\ResepMakananController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/resepmakanan/search', [ResepMakananController::class, 'search']); // 🔍 Pencarian Resep
Route::get('/resepmakanan/{id}', [ResepMakananController::class, 'show']); // 📜 Detail Resep
Route::get('/resepmakanan', [ResepMakananController::class, 'index']);
 