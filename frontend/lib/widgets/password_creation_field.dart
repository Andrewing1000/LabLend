import 'package:flutter/material.dart';
import 'package:frontend/themes/AppTheme.dart';

/// Una regla de la política de contraseñas que se puede revisar en el cliente.
class PasswordRule {
  final String label;
  final bool Function(String password) test;
  const PasswordRule(this.label, this.test);
}

/// Campo para elegir una contraseña nueva: muestra en vivo qué reglas de la
/// política se cumplen y un medidor de seguridad.
///
/// Las reglas son las mismas que valida el servidor (ver
/// docs/politica-contrasenas.md). Las que dependen de la cuenta (que no sea
/// común, ni parecida al usuario, ni una de las 5 últimas) solo las revisa el
/// servidor.
class PasswordCreationField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final double width;

  const PasswordCreationField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.width,
    this.labelText = 'Contraseña',
  });

  /// Caracteres especiales que acepta el servidor. Otros (como - . ? /) no
  /// cuentan.
  static const String specialCharacters = '~!@#\$%^&*()_+{}":;\'[]';

  static final List<PasswordRule> rules = [
    PasswordRule('Al menos 12 letras',
        (p) => RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').allMatches(p).length >= 12),
    PasswordRule('Una letra mayúscula', (p) => RegExp(r'[A-ZÁÉÍÓÚÜÑ]').hasMatch(p)),
    PasswordRule('Una letra minúscula', (p) => RegExp(r'[a-záéíóúüñ]').hasMatch(p)),
    PasswordRule('Un número', (p) => RegExp(r'\d').hasMatch(p)),
    PasswordRule('Un símbolo: ~ ! @ # \$ % ^ & * ( ) _ + { } " : ; \' [ ]',
        (p) => p.split('').any(specialCharacters.contains)),
  ];

  /// Cumple todas las reglas que se revisan en el cliente.
  bool isValid(String password) => rules.every((rule) => rule.test(password));

  /// Seguridad estimada de 0 a 1: reglas cumplidas, largo y variedad, con
  /// penalización por repeticiones y secuencias (aaa, abc, 123).
  double getStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = rules.where((rule) => rule.test(password)).length / rules.length * 0.7;

    if (password.length >= 16) strength += 0.15;
    if (password.split('').toSet().length > 12) strength += 0.15;

    if (RegExp(r'(.)\1\1').hasMatch(password)) strength -= 0.2;

    const sequences = ['abcdefghijklmnopqrstuvwxyz', '0123456789'];
    final lower = password.toLowerCase();
    for (final sequence in sequences) {
      for (int i = 0; i < sequence.length - 2; i++) {
        if (lower.contains(sequence.substring(i, i + 3))) strength -= 0.1;
      }
    }
    return strength.clamp(0, 1).toDouble();
  }

  @override
  State<PasswordCreationField> createState() => _PasswordCreationFieldState();
}

class _PasswordCreationFieldState extends State<PasswordCreationField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final password = widget.controller.text;
    final strength = widget.getStrength(password);
    final valid = widget.isValid(password);

    final (String level, Color color) = !valid
        ? ('Débil', AppColors.error)
        : strength < 0.85
            ? ('Aceptable', AppColors.warning)
            : ('Fuerte', AppColors.success);

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: widget.controller,
            obscureText: _isObscured,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText.isEmpty ? null : widget.hintText,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _isObscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
                icon: Icon(
                    _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              ),
            ),
          ),
          if (password.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: valid ? strength.clamp(0.4, 1.0) : strength.clamp(0.05, 0.35)),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 4,
                        color: color,
                        backgroundColor: AppColors.surfaceHighest,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  level,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Semantics(
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final rule in PasswordCreationField.rules)
                  _RuleRow(label: rule.label, met: rule.test(password)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String label;
  final bool met;

  const _RuleRow({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              met ? Icons.check : Icons.remove,
              key: ValueKey(met),
              size: 16,
              color: met ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              semanticsLabel: '$label: ${met ? 'cumplido' : 'pendiente'}',
              style: TextStyle(
                fontSize: 13,
                color: met ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
