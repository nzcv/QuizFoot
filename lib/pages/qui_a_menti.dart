import 'package:flutter/material.dart';

/// Page "Qui a menti ?"
/// Pour l'instant, cette page est vide.
/// Tu pourras ajouter ton contenu (texte, boutons, quiz, etc.) plus tard.
class QuiAMentiPage extends StatelessWidget {
  const QuiAMentiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar = barre en haut avec un titre
      appBar: AppBar(
        title: const Text("Qui a menti ?"),
        centerTitle: true, // centre le titre
      ),

      // Corps de la page (vide pour l'instant)
      body: const Center(
        child: Text(
          "Page en construction...",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}