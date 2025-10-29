class Pokemon {
  final String name;
  final String classification;

  const Pokemon({required this.name, required this.classification});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'] as String,
      classification: json['classification'] as String,
    );
  }

  @override
  String toString() {
    return 'Pokemon(name: $name, classification: $classification)';
  }
}
