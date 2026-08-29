import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/environment_config.dart';
import '../../data/repositories/pharmacy_repository.dart';
import '../../../auth/application/auth_provider.dart';
import '../widgets/pharmacy_catalog_view.dart';

class PharmacyScreen extends ConsumerStatefulWidget {
  const PharmacyScreen({super.key});

  @override
  ConsumerState<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends ConsumerState<PharmacyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _requestFormKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    // inicialización de controladores y recaptcha
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    GRecaptchaV3.ready(EnvironmentConfig.captchaSiteKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowPopup();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowPopup() async {
    // verifica si debe mostrar el mensaje de bienvenida para farmacias
    final box = await Hive.openBox('pharmacy_prefs');
    int visitCount = box.get('visit_count', defaultValue: 0);
    
    if (visitCount == 0 || (visitCount > 0 && visitCount % 3 == 0)) {
      if (mounted) {
        _showPharmacyPopup();
      }
    }
    await box.put('visit_count', visitCount + 1);
  }

  void _showPharmacyPopup() {
    // muestra el diálogo informativo sobre el portal profesional
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/farmacia/popup_farmacia.jpg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: AppColors.pharmacyGreen.withAlpha(50),
                            child: const Icon(Icons.local_pharmacy, size: 80, color: AppColors.pharmacyGreen),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Text(
                                '¡Bienvenido al Portal!',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Descubre las ventajas exclusivas para profesionales del sector farmacéutico.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.pharmacyGreen,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 45),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('EMPEZAR AHORA', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -15,
                  right: -15,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.cancel, color: Colors.red, size: 35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitForm() async {
    // envía la solicitud de alta para nuevas farmacias
    if (_requestFormKey.currentState!.validate() && _acceptedTerms) {
      setState(() => _isLoading = true);

      try {
        String? token;
        try {
          token = await GRecaptchaV3.execute('pharmacy_request');
        } catch (e) {
          await GRecaptchaV3.ready(EnvironmentConfig.captchaSiteKey);
          token = await GRecaptchaV3.execute('pharmacy_request');
        }
        
        await ref.read(pharmacyRepositoryProvider).submitPharmacyRequest(
          businessName: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          message: _messageController.text,
          captchaToken: token ?? '',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitud enviada. Verificaremos sus datos y contactaremos con usted.'),
              backgroundColor: AppColors.pharmacyGreen,
            ),
          );
          _requestFormKey.currentState!.reset();
          setState(() => _acceptedTerms = false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe aceptar los términos.'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _handlePharmacyLogin() async {
    // gestiona el acceso de usuarios profesionales
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? token;
      try {
        token = await GRecaptchaV3.execute('pharmacy_login');
      } catch (e) {
        await GRecaptchaV3.ready(EnvironmentConfig.captchaSiteKey);
        token = await GRecaptchaV3.execute('pharmacy_login');
      }
      
      await ref.read(authStateProvider.notifier).login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
        captchaToken: token,
      );

      if (mounted && ref.read(authStateProvider).value != null) {
        final isPharmacy = ref.read(authStateProvider.notifier).isPharmacy;
        if (isPharmacy) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bienvenido al Portal Farmacéutico'), backgroundColor: AppColors.pharmacyGreen),
          );
        } else {
          final authValue = ref.read(authStateProvider).value!;
          final roles = authValue.roles?.map((r) => r.toLowerCase()).toList() ?? [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Esta cuenta no tiene permisos de farmacia.'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // construcción de la interfaz del portal farmacéutico
    final isLoggedPharmacy = ref.watch(authStateProvider.notifier).isLoggedPharmacy;

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const CustomAppBar(title: 'Portal Farmacéutico', showBackButton: false),
      backgroundColor: Colors.grey.shade50,
      body: isLoggedPharmacy 
        ? const PharmacyCatalogView()
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                _buildAuthSection(context),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // cabecera visual de la sección de farmacia
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.pharmacyGreen, width: 4)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/farmacia/farmacia_header.webp',
            width: double.infinity, height: 250, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: double.infinity, height: 250, color: AppColors.pharmacyGreen.withAlpha(20), child: const Icon(Icons.local_pharmacy, size: 60, color: AppColors.pharmacyGreen)),
          ),
          Container(width: double.infinity, height: 250, color: Colors.black.withValues(alpha: 0.4)),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Text('Su Marca de Confianza', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text(
                  'Naviux acompaña a los profesionales farmacéuticos en el cuidado diario de la visión de sus pacientes. Únete a nuestra red de distribuidores autorizados.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context) {
    // sección de pestañas para solicitud de alta o inicio de sesión
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.pharmacyGreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.pharmacyGreen,
              tabs: const [
                Tab(text: 'SOLICITUD DE ALTA'),
                Tab(text: 'ACCESO PROFESIONAL'),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 650,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRequestForm(),
              _buildLoginForm(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestForm() {
    // formulario para solicitar el alta como farmacia
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        elevation: 6, shadowColor: AppColors.pharmacyGreen.withAlpha(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _requestFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader('Verificación de Farmacia', Icons.app_registration),
                const SizedBox(height: 24),
                _buildTextField('Nombre de la Farmacia', Icons.business, _nameController),
                const SizedBox(height: 16),
                _buildTextField('Correo Electrónico', Icons.email, _emailController, isEmail: true),
                const SizedBox(height: 16),
                _buildTextField('Teléfono de contacto', Icons.phone, _phoneController, isPhone: true),
                const SizedBox(height: 16),
                _buildTextField('Mensaje adicional', null, _messageController, maxLines: 3),
                const SizedBox(height: 16),
                _buildTermsCheckbox(),
                const SizedBox(height: 24),
                _buildSubmitButton('Enviar Solicitud', _submitForm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    // formulario de inicio de sesión para farmacias
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        elevation: 6, shadowColor: AppColors.pharmacyGreen.withAlpha(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader('Acceso Profesionales', Icons.vpn_key),
                const SizedBox(height: 24),
                _buildTextField('Email / Usuario', Icons.person, _loginEmailController),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _loginPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 32),
                _buildSubmitButton('Iniciar Sesión', _handlePharmacyLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.pharmacyGreen, size: 32),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary))),
      ],
    );
  }

  Widget _buildTextField(String label, IconData? icon, TextEditingController controller, {bool isEmail = false, bool isPhone = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.pharmacyGreen, width: 2)),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (isEmail && !v.contains('@')) return 'Email no válido';
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(value: _acceptedTerms, onChanged: (v) => setState(() => _acceptedTerms = v ?? false), activeColor: AppColors.pharmacyGreen),
        const Expanded(child: Text('Acepto términos y condiciones de privacidad', style: TextStyle(fontSize: 12))),
      ],
    );
  }

  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.pharmacyGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
