class Owner {
  final String id;
  final String name;

  Owner({required this.id, required this.name});

  factory Owner.fromMap(Map<String, dynamic> map) {
    return Owner(id: map["id"], name: map["name"]);
  }
}
