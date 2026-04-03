import 'package:get_it/get_it.dart';

import 'auth_service.dart';
import 'cloud_sync_service.dart';
import 'preference_service.dart';
import '../../features/boars/data/boar_repository.dart';
import '../../features/sows/data/sow_repository.dart';
import '../../features/insemination/data/insemination_repository.dart';
import '../../features/health/data/health_repository.dart';
import '../../features/commercial/data/commercial_repository.dart';
import '../../features/breeding/data/breeding_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ── Services ──────────────────────────────────────────────────────
  getIt.registerLazySingleton<PreferenceService>(() => PreferenceService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<CloudSyncService>(
      () => CloudSyncService(getIt<AuthService>()));

  // ── Repositories ──────────────────────────────────────────────────
  getIt.registerLazySingleton<BoarRepository>(
      () => BoarRepository(getIt<CloudSyncService>()));
  getIt.registerLazySingleton<SowRepository>(
      () => SowRepository(getIt<CloudSyncService>()));
  getIt.registerLazySingleton<InseminationRepository>(
      () => InseminationRepository(getIt<CloudSyncService>()));
  getIt.registerLazySingleton<HealthRepository>(
      () => HealthRepository(getIt<CloudSyncService>()));
  getIt.registerLazySingleton<CommercialRepository>(
      () => CommercialRepository(getIt<CloudSyncService>()));
  getIt.registerLazySingleton<BreedingRepository>(
      () => BreedingRepository(getIt<CloudSyncService>()));
}
