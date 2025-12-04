import 'package:flutter/material.dart';
import 'package:autochef/services/meal_plan.dart';

class MealPlanPopup {
  static void show(BuildContext context, {required int recipeId, required String recipeName}) {
    final List<Map<String, String>> daysData = [
      {'label': 'Min', 'value': 'Minggu'},
      {'label': 'Sen', 'value': 'Senin'},
      {'label': 'Sel', 'value': 'Selasa'},
      {'label': 'Rab', 'value': 'Rabu'},
      {'label': 'Kam', 'value': 'Kamis'},
      {'label': 'Jum', 'value': 'Jumat'},
      {'label': 'Sab', 'value': 'Sabtu'},
    ];
    
    int quantity = 1;
    List<String> selectedDays = [];
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  // --- JUDUL ---
                  const Text(
                    'Masak resep ini untuk hari apa?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: daysData.map((dayItem) {
                        final isSelected = selectedDays.contains(dayItem['value']);
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedDays.remove(dayItem['value']);
                                } else {
                                  selectedDays.add(dayItem['value']!);
                                }
                              });
                            },
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFFF46A06) // Orange
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF46A06)
                                      : Colors.black,
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                dayItem['label']!,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- PILIHAN PORSI ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mau masak berapa porsi?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (quantity > 1) {
                                setModalState(() {
                                  quantity--;
                                });
                              }
                            },
                            icon: const Icon(Icons.remove),
                            color: Colors.black,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: () {
                              setModalState(() {
                                quantity++;
                              });
                            },
                            icon: const Icon(Icons.add),
                            color: Colors.black,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFBC72A)))
                            : ElevatedButton(
                                onPressed: () async {
                                  if (selectedDays.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Pilih minimal satu hari!'),
                                        backgroundColor: Colors.orange,
                                        behavior: SnackBarBehavior.floating,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    return;
                                  }

                                  setModalState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    for (String day in selectedDays) {
                                      debugPrint('Menambahkan resep ke hari $day sebanyak $quantity porsi');
                                      await MealPlanService.addRecipeToMealPlan(
                                        day: day,
                                        recipeId: recipeId,
                                        quantity: quantity,
                                      );
                                    }

                                    if (!context.mounted) return;
                                    Navigator.pop(sheetContext); 

                                    String dayListStr = selectedDays.join(", ");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Berhasil ditambahkan ke: $dayListStr'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } catch (e) {
                                    setModalState(() {
                                      isLoading = false;
                                    });
                                    if (!context.mounted) return;
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString().replaceAll("Exception: ", "")),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFBC72A),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}