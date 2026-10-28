class ProvinesModels {
  final int id;
  final String name;

  ProvinesModels({required this.id, required this.name});

  factory ProvinesModels.fromJson(Map<String, dynamic> json) {
    return ProvinesModels(
      id: json['id'],
      name: json['name'],
    );
  }
}
