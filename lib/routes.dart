import 'package:flutter/material.dart';
import 'package:autochef/widgets/navbar.dart';
import 'package:autochef/views/recipe/recommendation_screen.dart';
import 'package:autochef/views/input_ingredients/input_screen.dart';
import 'package:autochef/views/recipe/recipe_detail_screen.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/intro/intro_screen.dart';
import 'package:autochef/login/login.dart';
import 'package:autochef/login/regis.dart';

class Routes {
  static const String introScreen = '/intro-screen';
  static const String home = '/home';
  static const String inputRecipe = '/input-recipe';
  static const String recommendationRecipe = '/recommendation-recipe';
  static const String detailMakanan = '/detail-makanan';
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case introScreen:
        return MaterialPageRoute(builder: (_) => const IntroScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const Navbar());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case inputRecipe:
        return MaterialPageRoute(builder: (_) => const InputRecipe());

      case recommendationRecipe:
        return MaterialPageRoute(
          builder: (_) => const RekomendationRecipe(bahan: []),
        );

      case detailMakanan:
        if (settings.arguments is Recipe) {
          final recipe = settings.arguments as Recipe;
          return MaterialPageRoute(
            builder: (_) => DetailMakanan(recipe: recipe),
          );
        }
        return MaterialPageRoute(builder: (_) => const Navbar());

      default:
        return MaterialPageRoute(builder: (_) => const Navbar());
    }
  }
}
