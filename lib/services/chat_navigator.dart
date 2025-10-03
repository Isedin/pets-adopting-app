import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/repositories/chat_repository.dart';
import 'package:pummel_the_fish/screens/chat_room_screen.dart';
import 'package:pummel_the_fish/widgets/auth_required_dialog.dart';

/// Single-responsibility helper to open (or create) a 1:1 chat.
/// - Centralizes auth checks & navigation
/// - Keeps UI "dumb" (no business logic in widgets)
class ChatNavigator {
  /// Tries to open chat with [otherUid].
  /// - If user is not logged in or is guest → shows auth dialog (AuthGate).
  /// - If chatting with self or no valid recipient → shows a friendly snackbar.
  static Future<void> openWith(BuildContext context, String? otherUid) async {
    // Validate recipient
    if (otherUid == null || otherUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recipient available for chat.')),
      );
      return;
    }

    final me = FirebaseAuth.instance.currentUser;

    // Not logged in / guest → route to login/register
    if (me == null || me.isAnonymous) {
      await showAuthRequiredDialog(context);
      return;
    }

    // Prevent chatting with yourself
    if (me.uid == otherUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't send a message to yourself.")),
      );
      return;
    }

    // Open or create the chat, then navigate
    try {
      final repo = context.read<ChatRepository>();
      final chatId = await repo.openOrCreateChatWith(otherUid);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: chatId)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open chat: $e')),
      );
    }
  }
}
