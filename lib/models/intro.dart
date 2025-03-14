class Intro {
  final String image;
  final String title;
  final String description;

  Intro({required this.image, required this.title, required this.description});
}

var introList = [
  Intro(
      image: "lib/assets/image1.png",
      title: "Welcome To AutoChef",
      description: "Temukan inspirasi masakan dari bahan yang ada di kulkas. Mudah, cepat, dan tanpa ribet!"),
  Intro(
      image: "lib/assets/image2.png",
      title: "Minimalisasi Food Waste",
      description: "Masak apapun dengan bahan yang kamu miliki. Hemat waktu dan lebih bergizi"),
  Intro(
      image: "lib/assets/image3.png",
      title: "Cook In Just 5 Minutes",
      description: "Resep cepat dengan bahan minimalis. Solusi praktis untuk masakan sehari-hari."),
];