import 'package:daily_expression/domain/time/clock.dart';

/// Test clock whose time can be moved forward at will.
class FakeClock implements Clock {
  FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}
