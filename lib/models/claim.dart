class Candidate {
  final String name;
  final bool isTrue;

  Candidate({required this.name, required this.isTrue});
}

class Claim {
  final String claim;
  final List<Candidate> candidates;

  Claim({required this.claim, required this.candidates});

  factory Claim.fromJson(Map<String, dynamic> json) {
    List<Candidate> candidates = [];
    for (int i = 1; i <= 10; i++) {
      final name = json['name$i'];
      final isTrue = json['isTrue$i'];

      if (name != null && name.toString().trim().isNotEmpty) {
        candidates.add(
          Candidate(
            name: name,
            isTrue: isTrue.toString().toLowerCase() == 'true',
          ),
        );
      }
    }
    return Claim(
      claim: json['claim'] ?? '',
      candidates: candidates,
    );
  }
}
