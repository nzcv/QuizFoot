import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match_model.dart';
import '../models/lineup_model.dart';

// Charger tous les matchs
Future<List<Match>> loadMatches() async {
  final url = Uri.parse('https://sheetdb.io/api/v1/awu5uvi0qdn9s?sheet=Matches');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((jsonItem) => Match.fromJson(jsonItem)).toList();
  } else {
    throw Exception('Impossible de charger les matchs : ${response.statusCode}');
  }
}

// Charger toutes les compositions
Future<List<Lineup>> loadLineups(String matchId) async {
  final url = Uri.parse('https://sheetdb.io/api/v1/awu5uvi0qdn9s?sheet=Lineups');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((jsonItem) => Lineup.fromJson(jsonItem)).toList();
  } else {
    throw Exception('Impossible de charger les lineups : ${response.statusCode}');
  }
}

