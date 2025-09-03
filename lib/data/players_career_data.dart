import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player_career.dart';

Future<List<PlayerCareer>> loadCareerPlayers() async {
  final url = Uri.parse('https://sheetdb.io/api/v1/awu5uvi0qdn9s?sheet=ParcoursJoueur');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((jsonItem) => PlayerCareer.fromJson(jsonItem)).toList();
  } else {
    throw Exception('Impossible de charger les joueurs carrière : ${response.statusCode}');
  }
}