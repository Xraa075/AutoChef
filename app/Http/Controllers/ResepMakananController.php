<?php
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ResepMakanan;

class ResepMakananController extends Controller
{
    public function index()
    {
        return response()->json(ResepMakanan::all());
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

        return response()->json($query->get());
    }

    public function show($id)
    {
        $resep = ResepMakanan::find($id);
        if (!$resep) {
            return response()->json(['message' => 'Resep tidak ditemukan'], 404);
        }
        return response()->json($resep);
    }
}
