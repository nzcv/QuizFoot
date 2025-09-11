class Match {
  final String matchId;
  final String matchName;
  final String competition;
  final String date;
  final String homeTeam;
  final String awayTeam;
  final String formationHome;
  final String formationAway;

  Match({
    required this.matchId,
    required this.matchName,
    required this.competition,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.formationHome,
    required this.formationAway,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['match_id'] as String,
      matchName: json['match_name'] as String,
      competition: json['competition'] as String,
      date: json['date'] as String,
      homeTeam: json['home_team'] as String,
      awayTeam: json['away_team'] as String,
      formationHome: json['formation_home'] as String,
      formationAway: json['formation_away'] as String,
    );
  }
}