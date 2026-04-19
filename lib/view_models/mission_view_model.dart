import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/module_model.dart';
import '../services/module_service.dart';

class MissionState {
  final List<ModuleModel> modules;
  final ModuleModel? activeModule;
  final bool isLoading;

  MissionState({
    this.modules = const [],
    this.activeModule,
    this.isLoading = false,
  });

  MissionState copyWith({
    List<ModuleModel>? modules,
    ModuleModel? activeModule,
    bool? isLoading,
  }) {
    return MissionState(
      modules: modules ?? this.modules,
      activeModule: activeModule ?? this.activeModule,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final moduleServiceProvider = Provider<ModuleService>((ref) => ModuleService());

final missionViewModelProvider = StateNotifierProvider<MissionViewModel, MissionState>(
  (ref) => MissionViewModel(ref.read(moduleServiceProvider)),
);

class MissionViewModel extends StateNotifier<MissionState> {
  final ModuleService _moduleService;

  MissionViewModel(this._moduleService) : super(MissionState());

  Future<void> fetchModules() async {
    state = state.copyWith(isLoading: true);
    try {
      final modules = await _moduleService.getModules();
      state = state.copyWith(isLoading: false, modules: modules);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectModule(String moduleId) {
    final module = state.modules.firstWhere((m) => m.id == moduleId);
    state = state.copyWith(activeModule: module);
  }
}
