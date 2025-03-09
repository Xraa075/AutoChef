//Model untuk data aplikasi
class Recipe {
  final String name;
  final String category;
  final String image;
  final int time;
  final int calories;
  final int protein;
  final int carbs;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    required this.name,
    required this.category,
    required this.image,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.ingredients,
    required this.steps,
  });
}
