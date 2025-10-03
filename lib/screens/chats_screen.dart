import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/repositories/chat_repository.dart';
import 'package:pummel_the_fish/logic/cubits/chat_list_cubit.dart';
import 'package:pummel_the_fish/screens/chat_room_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatListCubit(context.read<ChatRepository>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Chats')),
        body: BlocBuilder<ChatListCubit, ChatListState>(
          builder: (context, state) {
            if (state.loading) return const Center(child: CircularProgressIndicator());
            if (state.error != null) return Center(child: Text(state.error!));
            if (state.chats.isEmpty) return const Center(child: Text('No chats yet'));

            return ListView.separated(
              itemCount: state.chats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = state.chats[i];
                return ListTile(
                  title: Text(c.lastMessagePreview ?? '(no messages)'),
                  subtitle: Text('Members: ${c.participantIds.join(', ')}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: c.id)),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
