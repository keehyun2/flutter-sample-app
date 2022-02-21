import 'dart:async';
import 'dart:ui';

class TimeLate {
  final int milliseconds;
  Timer? _timer;

  TimeLate({required this.milliseconds});

  /// action 함수를 milliseconds 이후에 실행함. milliseconds 시간 안에 중복 호출시 마지막 호출만 실행
  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
