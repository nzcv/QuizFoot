import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service d'accès aux données SheetDB pour "Qui a menti ?"
class QuiAMentiApi {
  static const String _baseUrl = "https://sheetdb.io/api/v1/g2jtj2ps4cm5o"; 
  // Remplace par ton vrai endpoint SheetDB

  /// Récupère la liste des candidats et leur vérité associée.
  static Future<List<Map<String, dynamic>>> fetchClaims() async {
    final url = Uri.parse("$_baseUrl?sheet=candidates"); 
    // ⚠️ Vérifie que ta feuille s’appelle bien "candidates" dans Google Sheets/SheetDB

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Erreur API ${response.statusCode} : ${response.body}");
    }
  }
}
