import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pummel_the_fish/logic/cubits/auth_cubit.dart';
import 'package:pummel_the_fish/main.dart';
import 'package:pummel_the_fish/screens/chats_screen.dart';
import 'package:pummel_the_fish/screens/routes/adopted_pets_route.dart';
import 'package:pummel_the_fish/screens/routes/my_pets_route.dart';

class AccountMenu {
  /// Use a *stable* parentContext (e.g. from AppBar action) to avoid
  /// "deactivated widget" errors after closing the sheet.
  static Future<void> show(BuildContext parentContext) async {
    final auth = parentContext.read<AuthCubit>();          // keeping cubit reference
    final nav  = rootNavigatorKey.currentState;            // global navigator
    final sm   = rootMessengerKey.currentState;            // global snackbar
    final u = FirebaseAuth.instance.currentUser; // ok for display

    await showModalBottomSheet(
      context: parentContext,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(u?.email ?? 'Guest'),
              subtitle: Text(
                u == null
                    ? 'Not signed in'
                    : (u.isAnonymous
                        ? 'Guest session'
                        : (u.emailVerified ? 'Verified' : 'Not verified')),
              ),
            ),
            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('My Pets'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                nav?.push(MaterialPageRoute(builder: (_) => const MyPetsRoute()));
              },

            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Adopted Pets'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                nav?.push(MaterialPageRoute(builder: (_) => const AdoptedPetsRoute()));
              },

            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Chats'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                nav?.push(MaterialPageRoute(builder: (_) => const ChatsScreen()));
              },

            ),

            if (u != null && !u.isAnonymous && !u.emailVerified)
              ListTile(
                leading: const Icon(Icons.mark_email_unread_outlined),
                title: const Text('Send verification email'),
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  try {
                    final cur = FirebaseAuth.instance.currentUser;
                    await cur?.sendEmailVerification();
                    sm?.hideCurrentSnackBar();
                    sm?.showSnackBar(const SnackBar(content: Text('Verification email sent.')));
                  } catch (e) {
                    sm?.hideCurrentSnackBar();
                    sm?.showSnackBar(SnackBar(content: Text('Failed to send: $e')));
                  }
                },
              ),

            if (u != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();               // close sheet
                  auth.signOut().whenComplete(() {
                    sm?.hideCurrentSnackBar();
                    sm?.showSnackBar(const SnackBar(content: Text('Signed out.')));
                  });
                },

              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
