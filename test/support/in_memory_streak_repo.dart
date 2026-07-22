import 'package:daily_expression/domain/models/streak_state.dart';
import 'package:daily_expression/domain/repositories/streak_repository.dart';

/// In-memory [StreakRepository] for tests. Starts empty unless seeded.
class InMemoryStreakRepository implements StreakRepository {
  InMemoryStreakRepository([this.state = const StreakState()]);

  StreakState state;

  @override
  Future<StreakState> read() async => state;

  @override
  Future<void> save(StreakState state) async => this.state = state;
}
