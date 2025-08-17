import 'package:flutter/material.dart';

/// Modèle minimal pour un "candidat" à classer.
class Candidate {
  final String name;       // Nom complet affiché sur la carte
  final bool isTrueForClaim; // Indique si (selon nos données) l'affirmation est vraie pour ce joueur

  Candidate({required this.name, required this.isTrueForClaim});
}

/// Page de jeu "Qui a menti ?"
/// Étape 1 :
/// - Affiche une affirmation en haut.
/// - Affiche 10 cartes "À classer".
/// - Deux zones de dépôt : VRAI et FAUX.
/// - On peut glisser/déposer les cartes dans une zone, et les re-déplacer si besoin.
/// (Pas encore de bouton Valider ni de vérification 5/5 — ça arrive à l’étape 2)
class QuiAMentiPage extends StatefulWidget {
  const QuiAMentiPage({super.key});

  @override
  State<QuiAMentiPage> createState() => _QuiAMentiPageState();
}

class _QuiAMentiPageState extends State<QuiAMentiPage> {
  // -------------------
  // Données "en dur" pour POC
  // -------------------
  // Affirmation affichée en haut. (Tu mettras une vraie plus tard via JSON/API)
  final String claim = "J'ai marqué plus de 100 buts en Ligue 1";

  // 10 joueurs : 5 pour qui l'affirmation est vraie, 5 pour qui elle est fausse.
  // ⚠️ Ici c'est du DUMMY pour démo : le but est la mécanique, pas la véracité historique.
  // Tu remplaceras par des vraies données dans une prochaine étape.
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

  // -------------------
  // État des 3 colonnes : À classer / VRAI / FAUX
  // -------------------
  late List<Candidate> _toClassify; // liste de départ
  final List<Candidate> _trueBucket = [];
  final List<Candidate> _falseBucket = [];

  @override
  void initState() {
    super.initState();
    // On clone la liste source pour ne pas muter _allCandidates.
    _toClassify = List<Candidate>.from(_allCandidates);
  }

  // Utilitaire : retire un candidat de toutes les listes, puis l'ajoute dans "target"
  void _moveCandidate(Candidate c, List<Candidate> target) {
    setState(() {
      _toClassify.remove(c);
      _trueBucket.remove(c);
      _falseBucket.remove(c);
      target.add(c);
    });
  }

  // Widget réutilisable : une "carte" draggable pour un candidat
  Widget _draggableCard(Candidate c) {
    return LongPressDraggable<Candidate>(
      // data = l'objet qu'on transporte
      data: c,
      // "child" = rendu normal
      child: _candidateChip(c),
      // "feedback" = rendu sous le doigt pendant le drag (Material pour garder l'ombre/arrondis)
      feedback: Material(
        color: Colors.transparent,
        child: _candidateChip(c, elevated: true),
      ),
      // "childWhenDragging" = placeholder laissé à la place du child pendant le drag
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _candidateChip(c),
      ),
    );
  }

  // Petit chip visuel pour un candidat (utilisé partout)
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

  // Zone de drop générique (VRAI/FAUX) avec un titre et les items dedans (eux aussi redraggables)
  Widget _dropZone({
    required String title,
    required List<Candidate> bucket,
  }) {
    return DragTarget<Candidate>(
      // Quand un candidat est "au-dessus" de la zone de drop
      onWillAccept: (_) => true, // on accepte tout candidat
      // Quand on le lâche dans la zone
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
              // Wrap = permet de faire passer à la ligne les cartes
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

  // Colonne "À classer" (source) — les cartes sont aussi draggable
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar simple pour se repérer
      appBar: AppBar(
        title: const Text("Qui a menti ?"),
        centerTitle: true,
      ),

      // Corps : on reste simple et fonctionnel
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 1) L'affirmation du tour, bien visible
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

              // 2) Les 3 zones : À classer / VRAI / FAUX
              Expanded(
                child: Column(
                  children: [
                    // Ligne VRAI / FAUX (zones de drop)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _dropZone(title: "✅ VRAI", bucket: _trueBucket)),
                          Expanded(child: _dropZone(title: "❌ FAUX", bucket: _falseBucket)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Zone "À classer" en bas (source)
                    _toClassifyColumn(),
                  ],
                ),
              ),

              // 3) Le bouton "Valider" arrivera à l'étape 2 (avec règles 5/5 + feedback)
            ],
          ),
        ),
      ),
    );
  }
}
