class CareerClub {
  final String clubName;
  final String startYear;
  final String endYear;

  CareerClub({
    required this.clubName,
    required this.startYear,
    required this.endYear,
  });

  factory CareerClub.fromString(String s) {
    // Format attendu : "Arsenal 2003-2011"
    final parts = s.trim().split(' ');
    final club = parts.sublist(0, parts.length - 1).join(' ');
    final years = parts.last.split('-');
    return CareerClub(
      clubName: club,
      startYear: years[0],
      endYear: years.length > 1 ? years[1] : '',
    );
  }
}

class PlayerCareer {
  final int id;
  final String name;
  final String nationality;
  final String position;
  final String imageUrl;
  final List<CareerClub> careerClubs;
  final int difficulty;

  PlayerCareer({
    required this.id,
    required this.name,
    required this.nationality,
    required this.position,
    required this.imageUrl,
    required this.careerClubs,
    required this.difficulty,
  });

  factory PlayerCareer.fromJson(Map<String, dynamic> json) {
    final careerStr = json['career_clubs'] as String;
    final clubs = careerStr.split(';').map((s) => CareerClub.fromString(s)).toList();

    return PlayerCareer(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? 'Inconnu',
      nationality: json['nationality'] ?? '',
      position: json['position'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      careerClubs: clubs,
      difficulty: int.parse(json['difficulty']?.toString() ?? '5'),
    );
  }
}