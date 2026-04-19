import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingViewModelProvider = StateNotifierProvider<OnboardingViewModel, bool>(
  (ref) => OnboardingViewModel(),
);

class OnboardingViewModel extends StateNotifier<bool> {
  OnboardingViewModel() : super(false) {
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isOnboardingDone') ?? false;
  }

  Future<void> markOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardingDone', true);
    state = true;
  }
}
