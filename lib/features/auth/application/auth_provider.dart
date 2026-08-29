import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/auth_model.dart';
import '../data/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<AuthModel?> build() {
    // inicializa el estado de autenticación al construir el provider
    _init();
    return const AsyncValue.data(null);
  }

  Future<void> _init() async {
    // carga el usuario persistido si existe una sesión previa
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final isLoggedIn = await repository.isLoggedIn();
      
      if (isLoggedIn) {
        final persistedUser = await repository.getPersistedUser();
        state = AsyncValue.data(persistedUser);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String username, String password,
      {String? captchaToken}) async {
    // realiza el proceso de inicio de sesión y actualiza el estado
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final auth =
          await repository.login(username, password, captchaToken: captchaToken);
      state = AsyncValue.data(auth);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String captchaToken,
  }) async {
    // registra un nuevo usuario y establece la sesión
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final auth = await repository.register(
        username: username,
        email: email,
        password: password,
        captchaToken: captchaToken,
      );
      state = AsyncValue.data(auth);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    // gestiona el inicio de sesión a través de google
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final auth = await repository.signInWithGoogle();
      state = AsyncValue.data(auth);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    // cierra la sesión actual y limpia el estado
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  bool get isPharmacy {
    return state.value?.isPharmacy ?? false;
  }

  bool get isLoggedPharmacy {
    return state.value != null && isPharmacy;
  }
}
