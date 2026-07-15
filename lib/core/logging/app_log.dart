import 'package:logger/logger.dart';

/// Shared app logger. Uses [Logger]'s default [DevelopmentFilter], so output is
/// emitted in debug builds only and stays silent in release/profile.
final Logger logger = Logger(
  printer: PrettyPrinter(methodCount: 0, errorMethodCount: 6),
);

