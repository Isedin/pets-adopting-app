class AppSpecies {
  final String key;
  final String label;
  final bool builtin;
  final bool enabled;

  AppSpecies({
    required this.key,
    required this.label,
    this.builtin = false,
    this.enabled = true,
  });

  factory AppSpecies.fromMap(Map<String, dynamic> m) => AppSpecies(
    key: (m['key'] ?? '').toString(),
    label: (m['label'] ?? '').toString(),
    builtin: (m['builtin'] ?? false) == true,
    enabled: (m['enabled'] ?? true) == true,
  );

  Map<String, dynamic> toMap() => {
    'key': key,
    'label': label,
    'builtin': builtin,
    'enabled': enabled,
  };
}
