import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/badge_service.dart';
import '../services/challenge_service.dart';
import '../services/module_service.dart';
import '../services/user_service.dart';
import '../services/daily_login_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final badgeServiceProvider = Provider<BadgeService>((ref) => BadgeService());
final challengeServiceProvider = Provider<ChallengeService>((ref) => ChallengeService());
final moduleServiceProvider = Provider<ModuleService>((ref) => ModuleService());
final userServiceProvider = Provider<UserService>((ref) => UserService());
final dailyLoginServiceProvider = Provider<DailyLoginService>((ref) => DailyLoginService());

