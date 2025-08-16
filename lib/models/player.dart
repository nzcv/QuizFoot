class Player {
  final String name;
  final String imageUrl;
  final int level;

  Player({required this.name, required this.imageUrl, required this.level});

  factory Player.fromJson(Map<String, dynamic> json) {
  return Player(
    name: json['name'],
    imageUrl: json['imageUrl'],
    level: int.tryParse(json['level'].toString()) ?? 1,
    );
  }
}