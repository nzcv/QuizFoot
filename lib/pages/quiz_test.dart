import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../data/players_data.dart';

class QuizTest extends StatefulWidget {
  const QuizTest({super.key});

  @override
  State<QuizTest> createState() => _QuizTestState();
}

class _QuizTestState extends State<QuizTest> {
  List<Player> _players = [];
  late List<Player> _selectedPlayers;
  int _currentQuestion = 0;
  int _score = 0;
  String _answer = '';
  final TextEditingController _controller = TextEditingController();

  DateTime? _quizStartTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayersAndStartQuiz();
  }

  Future<void> _loadPlayersAndStartQuiz() async {
    final players = await loadPlayers();
    players.shuffle();
    setState(() {
      _players = players;
      _selectedPlayers = players.take(5).toList();
      _quizStartTime = DateTime.now();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    final trimmedAnswer = _answer.trim().toLowerCase();
    final correctAnswer = _selectedPlayers[_currentQuestion].name.toLowerCase();

    if (trimmedAnswer == correctAnswer) {
      _score++;
    }

    _controller.clear();

    if (_currentQuestion < _selectedPlayers.length - 1) {
      setState(() {
        _currentQuestion++;
        _answer = '';
      });
    } else {
      _showScorePage();
    }
  }

  Future<void> _saveResult(int score, int total, Duration timeTaken) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('quizHistory') ?? [];

    final now = DateTime.now();
    final formattedDate =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    String entry = '$formattedDate — Score: $score / $total';

    if (score == total) {
      entry += ' — Temps: ${timeTaken.inMinutes}m ${timeTaken.inSeconds % 60}s';
    }

    history.add(entry);
    await prefs.setStringList('quizHistory', history);
  }

  void _showScorePage() async {
    final quizEndTime = DateTime.now();
    final duration = quizEndTime.difference(_quizStartTime!);

    await _saveResult(_score, _selectedPlayers.length, duration);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScorePage(
          score: _score,
          total: _selectedPlayers.length,
          timeTaken: duration,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentPlayer = _selectedPlayers[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestion + 1} / ${_selectedPlayers.length}'),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    currentPlayer.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                autofocus: true,
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Quel joueur est-ce ?',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _answer = value;
                  });
                },
                onSubmitted: (_) {
                  if (_answer.trim().isNotEmpty) {
                    _submitAnswer();
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _answer.trim().isEmpty ? null : _submitAnswer,
                child: const Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScorePage extends StatelessWidget {
  final int score;
  final int total;
  final Duration timeTaken;

  const ScorePage({
    super.key,
    required this.score,
    required this.total,
    required this.timeTaken,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = timeTaken.inMinutes;
    final seconds = timeTaken.inSeconds % 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Résultat')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Score : $score / $total',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (score == total)
                Text(
                  'Bravo, tu as tout juste !\nTemps : ${minutes}m ${seconds}s',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: Colors.green),
                )
              else
                const Text(
                  'Bonne tentative, essaie encore !',
                  style: TextStyle(fontSize: 20),
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
