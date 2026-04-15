import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SplashStatus { initial, finish }

class SplashNotifier extends Notifier<SplashStatus> {
  @override
  SplashStatus build() => SplashStatus.initial;

  Future<void> moveToNextPage() async {
    await Future.delayed(const Duration(seconds: 2));
    state = SplashStatus.finish;
  }
}

final splashProvider =
    NotifierProvider<SplashNotifier, SplashStatus>(SplashNotifier.new);
