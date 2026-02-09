import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'navnavidation_state.dart';

class NavnavidationCubit extends Cubit<int> {
  NavnavidationCubit() : super(0);

  void changeTab(int index) {
    emit(index);
  }
}
