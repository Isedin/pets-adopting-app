import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/repositories/chat_repository.dart';
import 'package:pummel_the_fish/logic/cubits/chat_room_cubit.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  const ChatRoomScreen({super.key, required this.chatId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatRoomCubit(context.read<ChatRepository>(), widget.chatId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatRoomCubit, ChatRoomState>(
                builder: (context, state) {
                  if (state.loading) return const Center(child: CircularProgressIndicator());
                  if (state.error != null) return Center(child: Text(state.error!));

                  final msgs = state.messages;
                  if (msgs.isEmpty) return const Center(child: Text('Say hi 👋'));

                  return ListView.builder(
                    reverse: true,
                    itemCount: msgs.length,
                    itemBuilder: (_, i) {
                      final m = msgs[i];
                      final text = m.text ?? '🔒 [encrypted message]';
                      return ListTile(
                        title: Text(text),
                        subtitle: Text(m.senderId),
                        dense: true,
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: TextField(
                        controller: _ctrl,
                        decoration: const InputDecoration(hintText: 'Message'),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final txt = _ctrl.text.trim();
                      if (txt.isEmpty) return;
                      await context.read<ChatRoomCubit>().send(txt);
                      _ctrl.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
