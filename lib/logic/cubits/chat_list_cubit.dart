import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/models/chat.dart';
import 'package:pummel_the_fish/data/repositories/chat_repository.dart';

class ChatListState {
  final List<Chat> chats;
  final bool loading;
  final String? error;
  ChatListState({this.chats = const [], this.loading = true, this.error});

  ChatListState copyWith({List<Chat>? chats, bool? loading, String? error}) =>
      ChatListState(chats: chats ?? this.chats, loading: loading ?? this.loading, error: error);
}

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository repo;
  StreamSubscription? _sub;

  ChatListCubit(this.repo) : super(ChatListState()) {
    _sub = repo.watchMyChats().listen(
      (list) => emit(state.copyWith(chats: list, loading: false, error: null)),
      onError: (e) => emit(state.copyWith(loading: false, error: e.toString())),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
