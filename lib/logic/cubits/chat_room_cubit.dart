import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/models/chat_message.dart';
import 'package:pummel_the_fish/data/repositories/chat_repository.dart';

class ChatRoomState {
  final List<ChatMessage> messages;
  final bool loading;
  final String? error;
  ChatRoomState({this.messages = const [], this.loading = true, this.error});

  ChatRoomState copyWith({List<ChatMessage>? messages, bool? loading, String? error}) =>
      ChatRoomState(messages: messages ?? this.messages, loading: loading ?? this.loading, error: error);
}

class ChatRoomCubit extends Cubit<ChatRoomState> {
  final ChatRepository repo;
  final String chatId;
  StreamSubscription? _sub;

  ChatRoomCubit(this.repo, this.chatId) : super(ChatRoomState()) {
    _sub = repo.watchMessages(chatId).listen(
      (list) => emit(state.copyWith(messages: list, loading: false, error: null)),
      onError: (e) => emit(state.copyWith(loading: false, error: e.toString())),
    );
  }

  Future<void> send(String text) => repo.sendMessage(chatId, text);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
