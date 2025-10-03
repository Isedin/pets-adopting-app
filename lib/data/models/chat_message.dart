import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String? text;        // without E2EE
  final String? cipherText;  // with E2EE
  final String? nonce;       // for AES-GCM
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    this.text,
    this.cipherText,
    this.nonce,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> m, String id) {
     DateTime _asDateTime(dynamic v) {
      if (v == null) return DateTime.now();               // fallback
      if (v is Timestamp) return v.toDate();
      return DateTime.now();
    }
    return ChatMessage(
      id: id,
      senderId: m['senderId'] as String,
      text: m['text'] as String?, // optional
      cipherText: m['cipherText'] as String?,
      nonce: m['nonce'] as String?,
      createdAt: _asDateTime(m['createdAt']),
    );
  }

  Map<String, dynamic> toMapPlain(String text) => {
        'senderId': senderId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toMapEncrypted({
    required String cipherText,
    required String nonce,
  }) =>
      {
        'senderId': senderId,
        'cipherText': cipherText,
        'nonce': nonce,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
