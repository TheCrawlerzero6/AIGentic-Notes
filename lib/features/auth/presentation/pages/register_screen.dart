import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/auth/presentation/cubit/auth_state.dart';

import '../cubit/auth_cubit.dart';

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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    context.read<AuthCubit>().signUp(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
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
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            //gorouter
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 20,
                ),
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
                        style: TextStyle(fontSize: 14, color: Colors.black54),
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
                          onPressed: isLoading ? null : _handleRegister,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
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
          );
        },
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
