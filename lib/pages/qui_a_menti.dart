import 'package:flutter/material.dart';

/// Modèle minimal pour un "candidat" à classer.
class Candidate {
  final String name;       // Nom complet affiché sur la carte
  final bool isTrueForClaim; // Indique si (selon nos données) l'affirmation est vraie pour ce joueur

  Candidate({required this.name, required this.isTrueForClaim});
}

/// Page de jeu "Qui a menti ?"
class QuiAMentiPage extends StatefulWidget {
  const QuiAMentiPage({super.key});

  @override
  State<QuiAMentiPage> createState() => _QuiAMentiPageState();
}

class _QuiAMentiPageState extends State<QuiAMentiPage> {
  final String claim = "J'ai marqué plus de 100 buts en Ligue 1";

  final List<Candidate> _allCandidates = [
    Candidate(name: "Kylian Mbappé", isTrueForClaim: true),
    Candidate(name: "Edinson Cavani", isTrueForClaim: true),
    Candidate(name: "Wissam Ben Yedder", isTrueForClaim: true),
    Candidate(name: "Delio Onnis", isTrueForClaim: true),
    Candidate(name: "Bernard Lacombe", isTrueForClaim: true),
    Candidate(name: "Lionel Messi", isTrueForClaim: false),
    Candidate(name: "Cristiano Ronaldo", isTrueForClaim: false),
    Candidate(name: "Andrés Iniesta", isTrueForClaim: false),
    Candidate(name: "Paul Pogba", isTrueForClaim: false),
    Candidate(name: "Mohamed Salah", isTrueForClaim: false),
  ];

  late List<Candidate> _toClassify;
  final List<Candidate> _trueBucket = [];
  final List<Candidate> _falseBucket = [];

  @override
  void initState() {
    super.initState();
    _toClassify = List<Candidate>.from(_allCandidates);
  }

  void _moveCandidate(Candidate c, List<Candidate> target) {
    setState(() {
      _toClassify.remove(c);
      _trueBucket.remove(c);
      _falseBucket.remove(c);
      target.add(c);
    });
  }

  Widget _draggableCard(Candidate c) {
    return Draggable<Candidate>(
      data: c,
      child: _candidateChip(c),
      feedback: Material(
        color: Colors.transparent,
        child: _candidateChip(c, elevated: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _candidateChip(c),
      ),
    );
  }

  Widget _candidateChip(Candidate c, {bool elevated = false}) {
    return Card(
      elevation: elevated ? 6 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          c.name,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _dropZone({
    required String title,
    required List<Candidate> bucket,
  }) {
    return DragTarget<Candidate>(
      onWillAccept: (_) => true,
      onAccept: (candidate) => _moveCandidate(candidate, bucket),
      builder: (context, candidateData, rejected) {
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black12,
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in bucket) _draggableCard(c),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _toClassifyColumn() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("À classer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in _toClassify) _draggableCard(c),
            ],
          ),
        ],
      ),
    );
  }

  void _validate() {
  if (_trueBucket.length != 5 || _falseBucket.length != 5) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⚠️ Tu dois mettre exactement 5 joueurs dans chaque colonne !"),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  int correct = 0;
  for (var c in _trueBucket) {
    if (c.isTrueForClaim) correct++;
  }
  for (var c in _falseBucket) {
    if (!c.isTrueForClaim) correct++;
  }

  final success = correct == 10;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? "🎉 Bravo, tout est correct !"
            : "Tu as $correct/10 bonnes réponses. Essaie encore 😉",
      ),
      backgroundColor: success ? Colors.green : Colors.red,
      duration: const Duration(seconds: 2),
    ),
  );

  // Si tout est correct, redirection vers l'accueil après 2 secondes
  if (success) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Qui a menti ?"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Card(
                color: Colors.amber.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign, size: 26),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          claim,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _dropZone(title: "✅ VRAI", bucket: _trueBucket)),
                          Expanded(child: _dropZone(title: "❌ FAUX", bucket: _falseBucket)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _toClassifyColumn(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _validate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Valider", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
