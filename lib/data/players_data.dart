import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/player.dart';

Future<List<Player>> loadPlayers() async {
  final String jsonString = await rootBundle.loadString('assets/players.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((jsonItem) => Player.fromJson(jsonItem)).toList();
}