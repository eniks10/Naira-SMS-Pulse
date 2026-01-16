import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:naira_sms_pulse/features/auth/domian/repository/auth_repo.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthRepository _authRepo;
  SplashCubit({required AuthRepository authRepo})
    : _authRepo = authRepo,
      super(SplashInitial());

  Future<void> checkAuthStatusAndNavigate() async {
    final localUser = _authRepo.currentUser;
    print('HII${localUser}');
    if (localUser != null) {
      final result = await _authRepo.refreshSession();

      result.match(
        (result) async {
          print('User Absent');

          await _authRepo.logOut();
          emit(UnAuthenticatedState());
        },
        (result) {
          print('User present');
          emit(AuthenticatedState());
        },
      );
    } else {
      emit(UnAuthenticatedState());
    }

    //if user is logged in; check Token Storage Or Shared Preferences; emit Authenticated if not emit Unauthenticated
  }
}
