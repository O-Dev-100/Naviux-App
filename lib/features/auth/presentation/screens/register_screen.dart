import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/environment_config.dart';
import '../../application/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isRegistering = false;

  @override
  void initState() {
    // inicialización del recaptcha invisible para el registro
    super.initState();
    GRecaptchaV3.ready(EnvironmentConfig.captchaSiteKey);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // gestiona el proceso de registro de un nuevo usuario
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isRegistering = true);

    try {
      String? token;
      try {
        token = await GRecaptchaV3.execute('register');
      } catch (e) {
        await GRecaptchaV3.ready(EnvironmentConfig.captchaSiteKey);
        token = await GRecaptchaV3.execute('register');
      }
      
      if (token == null || token.isEmpty) {
        throw Exception('Error de verificación reCAPTCHA. Inténtalo de nuevo.');
      }

      await ref.read(authStateProvider.notifier).register(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            captchaToken: token,
          );

      if (mounted && ref.read(authStateProvider).value != null) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // construcción de la pantalla de creación de cuenta
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: const CustomAppBar(title: 'Crear Cuenta', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add_outlined, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'Únete a Naviux',
                style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Introduce un nombre de usuario' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || !v.contains('@') ? 'Introduce un email válido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
              ),
              const SizedBox(height: 32),
              _isRegistering 
                ? const CircularProgressIndicator(color: AppColors.primary)
                : AppButton(
                    text: 'Registrarse',
                    onPressed: _handleRegister,
                  ),
                  
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Al registrarte, aceptas nuestros términos y condiciones.',
                style: TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
