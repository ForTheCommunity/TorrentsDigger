import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'bookmarks_stats_event.dart';
part 'bookmarks_stats_state.dart';
part 'bookmarks_stats_bloc.freezed.dart';

class BookmarksStatsBloc
    extends Bloc<BookmarksStatsEvent, BookmarksStatsState> {
  BookmarksStatsBloc() : super(_Initial()) {
    on<_Load>(_load);
  }

  Future<void> _load(_Load event, Emitter<BookmarksStatsState> emit) async {
    emit(BookmarksStatsState.loading());
    try {
      InternalBookmarksStats bookmarksStats = await getBookmarksStats();
      emit(BookmarksStatsState.loaded(bookmarksStats: bookmarksStats));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }
}
