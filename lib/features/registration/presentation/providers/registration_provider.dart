import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/registration_remote_datasource.dart';
import '../../data/repository/registration_repository_impl.dart';
import '../../domain/models/registration_model.dart';
import '../../domain/repository/registration_repository.dart';

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  return RegistrationRepositoryImpl(RegistrationRemoteDataSource());
});

final registrationStateProvider = StateProvider<AsyncValue<void>>((ref) => const AsyncValue.data(null));

final registerBirthProvider = Provider.autoDispose.family<Future<void>, RegistrationRequest>((ref, request) async {
  final repository = ref.read(registrationRepositoryProvider);
  final state = ref.read(registrationStateProvider.notifier);
  state.state = const AsyncLoading();
  try {
    await repository.registerBirth(request);
    state.state = const AsyncData(null);
  } catch (e, st) {
    state.state = AsyncError(e, st);
    rethrow;
  }
});
