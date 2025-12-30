import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkAuthStatusAndNavigate() async {
    await Future.delayed(Duration(milliseconds: 3000));

    //if user is logged in; check Token Storage Or Shared Preferences; emit Authenticated if not emit Unauthenticated

    emit(AuthenticatedState());
  }
}
