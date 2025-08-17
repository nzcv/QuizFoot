import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

// =======================
// WIDGET DE FOND ANIMÉ
// =======================
class AnimatedBallBackground extends StatefulWidget {
  const AnimatedBallBackground({super.key});

  @override
  _AnimatedBallBackgroundState createState() => _AnimatedBallBackgroundState();
}

class _AnimatedBallBackgroundState extends State<AnimatedBallBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<Ball> _balls;
  ui.Image? _ballImage;

  @override
  void initState() {
    super.initState();

    // 1️⃣ Charger l'image du ballon depuis les assets
    _loadBallImage();

    // 2️⃣ Créer quelques ballons avec positions aléatoires
    _balls = List.generate(5, (index) {
      return Ball(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: 20 + _random.nextDouble() * 20,
        speed: 0.05 + _random.nextDouble() * 0.25, // vitesse plus lente
      );
    });

    // 3️⃣ Animation continue pour faire descendre les ballons
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(() {
        setState(() {
          for (var ball in _balls) {
            ball.y += ball.speed / 60;
            if (ball.y > 1.1) ball.y = -0.1; // Revenir en haut
          }
        });
      })
      ..repeat();
  }

  // =======================
  // CHARGEMENT DE L'IMAGE DU BALLON
  // =======================
  Future<void> _loadBallImage() async {
    final data = await rootBundle.load('assets/images/ball.png');
    final bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);
    setState(() {
      _ballImage = image;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si l'image n'est pas encore chargée, on affiche un loader
    if (_ballImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // CustomPaint pour dessiner le fond et les ballons
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: BallPainter(_balls, _ballImage!),
    );
  }
}

// =======================
// CLASSE POUR UN BALLON
// =======================
class Ball {
  double x; // position horizontale (0-1)
  double y; // position verticale (0-1)
  double radius; // taille du ballon
  double speed; // vitesse de descente

  Ball({required this.x, required this.y, required this.radius, required this.speed});
}

// =======================
// PAINTER DES BALLES
// =======================
class BallPainter extends CustomPainter {
  final List<Ball> balls;
  final ui.Image ballImage;
  BallPainter(this.balls, this.ballImage);

  @override
  void paint(Canvas canvas, Size size) {
    // 1️⃣ Dégradé vert pour le terrain
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Gradient gradient = LinearGradient(
      colors: [Colors.green[400]!, Colors.green[900]!],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final Paint backgroundPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

    // 2️⃣ Dessiner les ballons en PNG
    for (var ball in balls) {
      final double imgWidth = ball.radius;
      final double imgHeight = ball.radius;
      final Offset offset = Offset(
        ball.x * size.width - imgWidth / 2,
        ball.y * size.height - imgHeight / 2,
      );
      canvas.drawImageRect(
        ballImage,
        Rect.fromLTWH(0, 0, ballImage.width.toDouble(), ballImage.height.toDouble()),
        Rect.fromLTWH(offset.dx, offset.dy, imgWidth, imgHeight),
        Paint(),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =======================
// PAGE D'ACCUEIL
// =======================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBallBackground(), // Fond animé avec ballons PNG
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                  'assets/images/logo.png', // chemin vers ton logo
                  width: 250,  // tu ajustes la taille
                  height: 250,
                  ),

                  // Titre de l'app
                  const Text(
                    'Tempo',
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Sous-titre
                  const Text(
                    'Le jeu, dans la tête.',
                    style: TextStyle(fontSize: 24, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Bouton pour commencer le quiz
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/quiz_test');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 22),
                    ),
                    child: const Text('Coup d’œil'),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/qui_a_menti');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 22),
                    ),
                    child: const Text('Qui a menti ?'),
                  ),
                  const SizedBox(height: 20),

                  // Bouton pour voir les résultats
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/history_page');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Voir mes résultats'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
