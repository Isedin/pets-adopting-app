import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participantIds;
  final String? lastMessagePreview; // can be encrypted
  final DateTime? updatedAt;

  Chat({
    required this.id,
    required this.participantIds,
    this.lastMessagePreview,
    this.updatedAt,
  });

  factory Chat.fromMap(Map<String, dynamic> m, String id) {

    DateTime? _asDateTime(dynamic v) {
      if (v == null) return null;                         // allow null
      if (v is Timestamp) return v.toDate();
      return null;
    }

    return Chat(
      id: id,
      participantIds: (m['participantIds'] as List).map((e) => e.toString()).toList(),
      lastMessagePreview: m['lastMessage'] as String?,
      updatedAt: _asDateTime(m['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'participantIds': participantIds,
        'lastMessage': lastMessagePreview,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}