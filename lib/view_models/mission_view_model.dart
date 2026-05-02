import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/module_model.dart';
import '../services/module_service.dart';
import '../providers/service_providers.dart';
class MissionState {
  final List<ModuleModel> modules;
  final ModuleModel? activeModule;
  final bool isLoading;
  final String? errorMessage;

  MissionState({
    this.modules = const [],
    this.activeModule,
    this.isLoading = false,
    this.errorMessage,
  });

  MissionState copyWith({
    List<ModuleModel>? modules,
    ModuleModel? activeModule,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MissionState(
      modules: modules ?? this.modules,
      activeModule: activeModule ?? this.activeModule,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}


final missionViewModelProvider = StateNotifierProvider<MissionViewModel, MissionState>(
  (ref) => MissionViewModel(ref.read(moduleServiceProvider)),
);

class MissionViewModel extends StateNotifier<MissionState> {
  final ModuleService _moduleService;

  MissionViewModel(this._moduleService) : super(MissionState());

  Future<void> fetchModules() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final modules = await _moduleService.getModules();
      state = state.copyWith(isLoading: false, modules: modules);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectModule(String moduleId) {
    final module = state.modules.firstWhere((m) => m.id == moduleId);
    state = state.copyWith(activeModule: module);
  }
}
