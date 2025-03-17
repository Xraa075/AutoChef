<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ResepMakanan extends Model
{
    use HasFactory;

    protected $table = 'resep_makanan'; // Nama tabel di database
    protected $primaryKey = 'id'; // Primary Key
    public $timestamps = false; // Matikan jika tabel tidak punya created_at & updated_at

    protected $fillable = [
        'nama_resep', 'bahan', 'steps', 'gambar' // Kolom yang bisa diisi
    ];
}
