import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pummel_the_fish/data/models/chat.dart';
import 'package:pummel_the_fish/data/models/chat_message.dart';
import 'package:pummel_the_fish/services/chat_crypto.dart';
import 'package:cryptography/cryptography.dart';

class ChatRepository {
  final FirebaseFirestore firestore;
  final ChatCrypto crypto;

  ChatRepository({required this.firestore, required this.crypto});

  CollectionReference get _chats => firestore.collection('chats');
  CollectionReference get _users => firestore.collection('users');

  // Ensure my user profile contains public key for E2EE.
  Future<void> _ensureMyUserDoc() async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null || me.isAnonymous) return; // block guests at UI anyway

    final pub = await crypto.exportPublicKey(); // Uint8List
    await _users.doc(me.uid).set({
      'displayName': me.displayName,
      'email': me.email,
      'publicKey': base64Encode(pub),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> _ensureChat(String otherUid) async {
    final me = FirebaseAuth.instance.currentUser!;
    await _ensureMyUserDoc(); // make sure my key exists

    final q = await _chats
        .where('participantIds', arrayContains: me.uid)
        .get();

    // try to find existing 1:1
    for (final d in q.docs) {
      final ids = List<String>.from(d['participantIds'] as List);
      if (ids.length == 2 && ids.contains(otherUid)) {
        return d.id;
      }
    }

    // create new
    final doc = await _chats.add({
      'participantIds': [me.uid, otherUid],
      'lastMessage': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<String> openOrCreateChatWith(String otherUid) => _ensureChat(otherUid);

  Stream<List<Chat>> watchMyChats() {
    final me = FirebaseAuth.instance.currentUser!;
    // ensure once per subscription
    _ensureMyUserDoc();
    return _chats
        .where('participantIds', arrayContains: me.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Chat.fromMap(d.data() as Map<String,dynamic>, d.id)).toList());
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    _ensureMyUserDoc();
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .asyncMap((snap) async {
          final msgs = snap.docs.map((d) => ChatMessage.fromMap(d.data(), d.id)).toList();

          // attempt E2EE decrypt
          final shared = await _trySharedSecret(chatId);
          if (shared == null) return msgs; // plain or not ready

          final out = <ChatMessage>[];
          for (final m in msgs) {
            if (m.cipherText != null && m.nonce != null) {
              try {
                final plain = await crypto.decrypt(shared, m.cipherText!, m.nonce!);
                out.add(ChatMessage(
                  id: m.id,
                  senderId: m.senderId,
                  text: plain,
                  createdAt: m.createdAt,
                ));
              } catch (_) {
                out.add(m); // leave as-is if decrypt fails
              }
            } else {
              out.add(m); // plain
            }
          }
          return out;
        });
  }

  Future<void> sendMessage(String chatId, String text) async {
    final me = FirebaseAuth.instance.currentUser!;
    await _ensureMyUserDoc();

    final msgCol = _chats.doc(chatId).collection('messages');
    final shared = await _trySharedSecret(chatId);

    if (shared == null) {
      // fallback: send as plain text while keys propagate
      final map = ChatMessage(
        id: 'tmp',
        senderId: me.uid,
        text: text,
        createdAt: DateTime.now(),
      ).toMapPlain(text);

      await msgCol.add(map);
      await _chats.doc(chatId).update({
        'lastMessage': text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final enc = await crypto.encrypt(shared, text);
    await msgCol.add({
      'senderId': me.uid,
      'cipherText': enc['cipherText'],
      'nonce': enc['nonce'],
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _chats.doc(chatId).update({
      'lastMessage': '[encrypted]',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // === helpers ===

  Future<SecretKey?> _trySharedSecret(String chatId) async {
    final me = FirebaseAuth.instance.currentUser!;
    final chatDoc = await _chats.doc(chatId).get();
    final ids = List<String>.from(chatDoc['participantIds'] as List);
    final other = ids.firstWhere((u) => u != me.uid, orElse: () => me.uid);

    // fetch public keys
    // final mePub  = await crypto.myPublicKey(); // from secure storage
    final otherUser = await firestore.collection('users').doc(other).get();
    final otherPubB64 = otherUser.data()?['publicKey'] as String?;
    if (otherPubB64 == null) return null;

    final otherPub = SimplePublicKey(
      base64Decode(otherPubB64),
      type: KeyPairType.x25519,
    );
    return await crypto.deriveSharedSecret(otherPub);
  }
}
