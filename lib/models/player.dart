class Player {
  final String name;
  final String imageUrl;
  final int level;

  Player({required this.name, required this.imageUrl});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      level: json['level'] as int,
    );
  }
}