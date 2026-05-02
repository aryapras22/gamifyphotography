import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/module_model.dart';
import '../services/module_service.dart';
import '../providers/service_providers.dart';

const _unset = Object();

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
    Object? activeModule = _unset,
    bool? isLoading,
    Object? errorMessage = _unset,
  }) {
    return MissionState(
      modules: modules ?? this.modules,
      activeModule: activeModule == _unset
          ? this.activeModule
          : activeModule as ModuleModel?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

final missionViewModelProvider =
    StateNotifierProvider<MissionViewModel, MissionState>(
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

  void markModuleCompleted(String moduleId) {
    final updatedModules = state.modules.map((m) {
      if (m.id == moduleId) return m.copyWith(isCompleted: true);
      return m;
    }).toList();
    state = state.copyWith(modules: updatedModules);
  }
}
