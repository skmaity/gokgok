import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokgok/features/splash/bloc/splash_event.dart';
import 'package:gokgok/features/splash/bloc/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashScreenInitial()) {
    on<SplashMoveToNextPage>((event, emit) async {
      await Future.delayed(Duration(seconds: 2));
      emit(SplashScreenFinish());
    });
  }
}
