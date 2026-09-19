import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<int> {
  AuthCubit() : super(0);

  void login() => emit(state + 1);
  void signup() => emit(state + 1);
}
