import 'package:autochef/models/recipe.dart';

List<Recipe> dummyRecipes = [
  Recipe(
    name: "Pancake",
    category: "Western",
    image: "lib/assets/images/pancake.jpg",
    time: 5,
    calories: 312,
    protein: 13,
    carbs: 9,
    ingredients: [
      "100 gram Tepung Terigu",
      "2 sendok makan Gula Pasir",
      "1 butir telur",
      "1 sendok teh Baking Powder"
    ],
    steps: [
      "Campur bahan kering: tepung, gula, baking powder, dan garam.",
      "Kocok telur, tambahkan susu dan mentega yang dilelehkan.",
      "Gabungkan adonan, aduk hingga rata.",
      "Panaskan wajan dengan sedikit mentega.",
      "Tuang adonan, masak hingga muncul gelembung lalu balik.",
      "Angkat dan sajikan dengan topping favorit."
    ],
  ),
];
