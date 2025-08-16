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

  // On clone la liste pour pouvoir retirer les joueurs déjà sélectionnés
  final remainingPlayers = List<Player>.from(players);

  List<Player> selected = [];

  // 1 joueur level 1
  selected.add(_pickRandomPlayer(remainingPlayers, [1]));
  remainingPlayers.remove(selected.last);

  // 2 joueurs level 2 ou 3
  for (int i = 0; i < 2; i++) {
    final player = _pickRandomPlayer(remainingPlayers, [2, 3]);
    selected.add(player);
    remainingPlayers.remove(player);
  }

  // 2 joueurs level 4 ou 5
  for (int i = 0; i < 2; i++) {
    final player = _pickRandomPlayer(remainingPlayers, [4, 5]);
    selected.add(player);
    remainingPlayers.remove(player);
  }

  // 2 joueurs level 6 ou 7
  for (int i = 0; i < 2; i++) {
    final player = _pickRandomPlayer(remainingPlayers, [6, 7]);
    selected.add(player);
    remainingPlayers.remove(player);
  }

  // 2 joueurs level 8 ou 9
  for (int i = 0; i < 2; i++) {
    final player = _pickRandomPlayer(remainingPlayers, [8, 9]);
    selected.add(player);
    remainingPlayers.remove(player);
  }

  // 1 joueur level 10
  selected.add(_pickRandomPlayer(remainingPlayers, [10]));
  remainingPlayers.remove(selected.last);

  for (var p in selected) {
  print('Player: ${p.name}, Level: ${p.level}');
};

  setState(() {
    _players = players;
    _selectedPlayers = selected;
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

  Player _pickRandomPlayer(List<Player> players, List<int> levels) {
  final filtered = players.where((p) => levels.contains(p.level)).toList();
  if (filtered.isEmpty) {
    // Si aucun joueur dans ce niveau, on cherche dans le niveau supérieur
    final maxLevel = players.map((p) => p.level).reduce((a, b) => a > b ? a : b);
    for (int lvl in levels) {
      if (lvl < maxLevel) {
        return _pickRandomPlayer(players, [lvl + 1]);
      }
    }
    // fallback : on prend un joueur au hasard
    return players[(players.length * (0.5)).toInt()]; 
  }
  filtered.shuffle();
  return filtered.first;
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child: Image.network(
            currentPlayer.imageUrl,
            fit: BoxFit.contain,
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

        const SizedBox(height: 16),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
      ],
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
