import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/claim.dart';

class QuiAMentiApi {
  static const String baseUrl = "https://sheetdb.io/api/v1/g2jtj2ps4cm5o";

  static Future<List<Claim>> fetchRandomClaim() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception("Erreur API SheetDB : ${response.statusCode}");
    }

    final List<dynamic> data = jsonDecode(response.body);

    // On mappe chaque ligne du sheet en Claim
    return data.map((json) => Claim.fromJson(json)).toList();
  }
}
