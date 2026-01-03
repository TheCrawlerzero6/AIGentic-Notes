import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

/// Pantalla de registro de nuevos usuarios
/// 
/// Permite crear cuenta con validaciones:
/// - Username no vacío
/// - Email válido
/// - Contraseña mínimo 6 caracteres
/// - Confirmación de contraseña coincidente
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  /// Validación de email con regex básico
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  /// Validación de contraseña mínimo 6 caracteres
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  /// Validación de confirmación de contraseña
  String? _validateConfirmPassword(String? value) {
    if (value != _passwordCtrl.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Maneja el registro de usuario
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (!mounted) return;

      if (success) {
        // Registro exitoso → Navegar a Login para que inicie sesión
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada exitosamente. Inicia sesión'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'El usuario ya existe';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al registrar: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Crear Cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Regístrate para empezar a organizar tus tareas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B0A1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.event_note,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  _label('Usuario'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: _inputDecoration('Tu nombre de usuario'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'El usuario es obligatorio'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  _label('Correo'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('user@email.com'),
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 16),

                  _label('Contraseña'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: _inputDecoration('Mínimo 6 caracteres'),
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 16),

                  _label('Confirmar Contraseña'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: true,
                    decoration: _inputDecoration('Repite tu contraseña'),
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6750A4),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Registrarse',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Ya tienes cuenta? ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Inicia Sesión',
                          style: TextStyle(
                            color: Color(0xFF6750A4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
