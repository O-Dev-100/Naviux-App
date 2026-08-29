import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import '../../application/auth_provider.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/environment_config.dart';
import 'package:naviux_app/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isCheckingCaptcha = false;
  bool _isSigningWithGoogle = false;

  @override
  void initState() {
    // inicialización del recaptcha invisible
    super.initState();
    GRecaptchaV3.ready(EnvironmentConfig.captchaSiteKey);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // gestiona el proceso de inicio de sesión estándar
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCheckingCaptcha = true);

    try {
      String? token;
      try {
        token = await GRecaptchaV3.execute('login');
      } catch (e) {
        await GRecaptchaV3.ready(EnvironmentConfig.captchaSiteKey);
        token = await GRecaptchaV3.execute('login');
      }

      if (token == null || token.isEmpty) {
        token = '';
      }

      await ref
          .read(authStateProvider.notifier)
          .login(
            _identifierController.text.trim(),
            _passwordController.text,
            captchaToken: token,
          );

      if (mounted && ref.read(authStateProvider).value != null) {
        final authModel = ref.read(authStateProvider).value!;
        if (authModel.isPharmacy) {
          context.go('/pharmacy');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('Exception')
                  ? e.toString().split(':').last
                  : e.toString(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingCaptcha = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    // gestiona el inicio de sesión con google
    if (_isCheckingCaptcha || _isSigningWithGoogle) return;

    setState(() => _isSigningWithGoogle = true);

    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();

      if (mounted && ref.read(authStateProvider).value != null) {
        final authModel = ref.read(authStateProvider).value!;
        if (authModel.isPharmacy) {
          context.go('/pharmacy');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('Exception')
                  ? e.toString().split(':').last
                  : e.toString(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSigningWithGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // construcción de la pantalla de acceso
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: CustomAppBar(title: l10n.drawerLogin, showBackButton: true),
      body: authState.when(
        data: (user) {
          if (user != null) {
            return _buildAlreadyLoggedIn(context, user);
          }
          return _buildLoginForm(context, theme, l10n);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return _buildLoginForm(context, theme, l10n, errorMessage: error.toString());
        },
      ),
    );
  }

  Widget _buildAlreadyLoggedIn(BuildContext context, dynamic user) {
    // vista cuando el usuario ya tiene una sesión activa
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Ya has iniciado sesión',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Hola, ${user.userDisplayName}. Ya estás dentro de tu cuenta Naviux.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('IR AL INICIO'),
              ),
            ),
            TextButton(
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
              child: const Text('Cerrar sesión e iniciar con otra cuenta', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, ThemeData theme, AppLocalizations l10n, {String? errorMessage}) {
    // construcción del formulario de inicio de sesión
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage.contains('AuthException') 
                              ? errorMessage.split(':').last 
                              : 'Error al iniciar sesión. Por favor, inténtalo de nuevo.',
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const Icon(
                Icons.lock_person_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),

              TextFormField(
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.isEmpty
                    ? 'Introduce tu usuario o email'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Email / Usuario',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
                validator: (v) =>
                    v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text('¿Has olvidado tu contraseña?'),
                ),
              ),

              const SizedBox(height: 32),

              ref
                  .watch(authStateProvider)
                  .maybeWhen(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    orElse: () => _isCheckingCaptcha || _isSigningWithGoogle
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : AppButton(
                            text: 'Iniciar Sesión',
                            onPressed: _handleLogin,
                          ),
                  ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Continuar con Google',
                icon: Icons.g_mobiledata,
                isPrimary: false,
                onPressed: _handleGoogleLogin,
                isLoading: _isSigningWithGoogle,
              ),
              const SizedBox(height: 24),
              const Text(
                'Este sitio utiliza reCAPTCHA invisible para garantizar tu seguridad.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),
              
              Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.local_pharmacy, color: AppColors.pharmacyGreen),
                    label: const Text('ACCESO PARA FARMACIAS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pharmacyGreen)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usa tus credenciales de farmacia para acceder al panel profesional.'),
                          backgroundColor: AppColors.pharmacyGreen,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.pharmacyGreen, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?'),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
