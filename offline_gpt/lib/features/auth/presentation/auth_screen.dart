import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/tech_theme.dart';
import '../state/auth_controller.dart';
import '../state/auth_state.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _loginKey = GlobalKey<FormState>();
  final _registerKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: TechPalette.background,
        body: Stack(
          children: [
            const TechBackground(),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OfflineGPT',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: TechPalette.textPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connexion securisee pour telecharger vos modeles IA.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: TechPalette.textMuted,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _TechChip(label: 'JWT Secure'),
                            _TechChip(label: 'Offline Ready'),
                            _TechChip(label: 'Local First'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: TechPalette.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: TechPalette.outline),
                      ),
                      child: const TabBar(
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TechPalette.accent,
                              TechPalette.accentAlt,
                            ],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: TechPalette.background,
                        unselectedLabelColor: TechPalette.textMuted,
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: 'Connexion'),
                          Tab(text: 'Inscription'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _AuthCard(
                          title: 'Connexion rapide',
                          subtitle: 'Accedez a vos packs locaux en quelques secondes.',
                          child: _LoginForm(
                            formKey: _loginKey,
                            emailController: _loginEmailController,
                            passwordController: _loginPasswordController,
                            isLoading: isLoading,
                            errorMessage: authState.errorMessage,
                            onSubmit: () async {
                              if (_loginKey.currentState?.validate() != true) {
                                return;
                              }
                              await ref.read(authControllerProvider.notifier).login(
                                    email: _loginEmailController.text.trim(),
                                    password: _loginPasswordController.text,
                                  );
                            },
                          ),
                        ),
                        _AuthCard(
                          title: 'Inscription securisee',
                          subtitle: 'Creez votre compte pour telecharger les modeles.',
                          child: _RegisterForm(
                            formKey: _registerKey,
                            nameController: _registerNameController,
                            emailController: _registerEmailController,
                            passwordController: _registerPasswordController,
                            isLoading: isLoading,
                            errorMessage: authState.errorMessage,
                            onSubmit: () async {
                              if (_registerKey.currentState?.validate() != true) {
                                return;
                              }
                              await ref.read(authControllerProvider.notifier).register(
                                    fullName:
                                        _registerNameController.text.trim(),
                                    email: _registerEmailController.text.trim(),
                                    password: _registerPasswordController.text,
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _TechChip extends StatelessWidget {
  final String label;

  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TechPalette.surfaceStrong,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TechPalette.outline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: TechPalette.textMuted,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _AuthCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, animatedChild) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: Opacity(opacity: value, child: animatedChild),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: TechPalette.surfaceStrong.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TechPalette.outline),
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: TechPalette.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TechPalette.textMuted,
                          ),
                    ),
                    const SizedBox(height: 20),
                    child,
                    const SizedBox(height: 12),
                    Text(
                      'Tokens stockes en securite sur l appareil.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: TechPalette.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: errorMessage == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(errorMessage),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TechPalette.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TechPalette.error),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: TechPalette.error),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          _AuthField(
            controller: emailController,
            label: 'Email',
            icon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email requis';
              }
              if (!value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller: passwordController,
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Minimum 8 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Se connecter',
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: errorMessage == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(errorMessage),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TechPalette.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TechPalette.error),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: TechPalette.error),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          _AuthField(
            controller: nameController,
            label: 'Nom complet',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().length < 2) {
                return 'Nom requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller: emailController,
            label: 'Email',
            icon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email requis';
              }
              if (!value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller: passwordController,
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Minimum 8 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: "S'inscrire",
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?) validator;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: TechPalette.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: TechPalette.textMuted),
        prefixIcon: Icon(icon, color: TechPalette.textMuted),
        filled: true,
        fillColor: TechPalette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TechPalette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TechPalette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TechPalette.accent, width: 1.6),
        ),
      ),
      validator: validator,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: TechPalette.accent,
          foregroundColor: TechPalette.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: TechPalette.background,
                ),
              )
            : Text(label),
      ),
    );
  }
}

