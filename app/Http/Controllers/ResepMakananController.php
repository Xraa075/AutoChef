<?php
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ResepMakanan;

class ResepMakananController extends Controller
{
    public function index()
    {
        $data = ResepMakanan::all();
        return response()->json([
            'message' => count($data) > 0 ? 'Data resep berhasil diambil' : 'Tidak ada data resep',
            'data' => $data
        ]);
    }

    public function search(Request $request)
    {
        $query = ResepMakanan::query();

        if ($request->has('nama_resep')) {
            $query->where('nama_resep', 'like', '%' . $request->nama_resep . '%');
        }

        if ($request->has('bahan')) {
            $bahanArray = explode(',', $request->bahan);
            foreach ($bahanArray as $bahan) {
                $query->where('bahan', 'like', '%' . trim($bahan) . '%');
            }
        }

        $data = $query->get();
        return response()->json([
            'message' => count($data) > 0 ? 'Resep ditemukan berdasarkan pencarian' : 'Tidak ada resep yang cocok',
            'data' => $data
        ]);
    }

    public function show($id)
    {
        $resep = ResepMakanan::find($id);
        if (!$resep) {
            return response()->json([
                'message' => 'Resep tidak ditemukan',
                'data' => null
            ], 404);
        }
        return response()->json([
            'message' => 'Resep berhasil ditemukan',
            'data' => $resep
        ]);
    }
}