import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/models/User.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/app_nav.dart';
import 'package:provider/provider.dart';

/// "Mi perfil": datos de la cuenta, estado de la contraseña (cuándo vence,
/// D21) y la política de contraseñas que aplica el servidor.
class ProfilePage extends PageBase {
  final VoidCallback onChangePassword;

  ProfilePage({super.key, required this.onChangePassword});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  @override
  void onDispose() {}

  @override
  void onSet() {}
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: SessionManager(),
      child: Consumer<SessionManager>(
        builder: (context, sessionManager, _) {
          final user = sessionManager.session.user;
          if (user is VisitorUser) {
            return const Center(
              child: Text('Inicie sesión para ver su perfil.',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          final compact = AppBreakpoints.isCompact(context);
          return SingleChildScrollView(
            padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _IdentityCard(user: user),
                    const SizedBox(height: AppSpacing.lg),
                    _PasswordCard(user: user, onChangePassword: widget.onChangePassword),
                    const SizedBox(height: AppSpacing.lg),
                    const _PolicyCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CardTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(text,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final User user;
  const _IdentityCard({required this.user});

  static String _readable(String name) =>
      name.replaceAllMapped(RegExp(r'(?<=[a-záéíóúñ])(?=[A-ZÁÉÍÓÚÑ])'), (_) => ' ');

  @override
  Widget build(BuildContext context) {
    final color = user.securityAccount ? AppColors.warning : AppColors.primary;
    return _Card(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Text(userInitials(user),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          ),
          const SizedBox(width: AppSpacing.lg + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: user.username,
                        style: const TextStyle(
                            fontFamily: 'monospace', color: AppColors.textSecondary)),
                    const TextSpan(text: '  ·  '),
                    TextSpan(text: user.email),
                  ]),
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs + 2,
                  runSpacing: AppSpacing.xs + 2,
                  children: [
                    for (final role in user.roles)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm + 2, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(_readable(role),
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado de la contraseña: cuándo vence, cuánto le queda y el botón para
/// cambiarla.
class _PasswordCard extends StatelessWidget {
  final User user;
  final VoidCallback onChangePassword;
  const _PasswordCard({required this.user, required this.onChangePassword});

  static const _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
    'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];

  static String _date(DateTime d) => '${d.day} de ${_months[d.month - 1]} de ${d.year}';

  @override
  Widget build(BuildContext context) {
    const lifeDays = 90;
    final expiresAt = user.passwordExpiresAt;
    final days = user.passwordDaysLeft;

    final (String label, IconData icon, Color color) = user.passwordExpired || (days != null && days <= 0)
        ? ('Vencida', Icons.error_outline, AppColors.error)
        : user.passwordExpiresSoon
            ? ('Vence pronto', Icons.warning_amber_rounded, AppColors.warning)
            : ('Vigente', Icons.check_circle_outline, AppColors.success);

    final remaining = days == null ? 0.0 : (days / lifeDays).clamp(0.0, 1.0);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: _CardTitle(icon: Icons.key_outlined, text: 'Contraseña')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Text(label,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (expiresAt != null && days != null) ...[
            Text.rich(
              TextSpan(children: [
                TextSpan(text: days > 0 ? 'Vence el ' : 'Venció el '),
                TextSpan(
                    text: _date(expiresAt),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                if (days > 0) TextSpan(text: '  ·  quedan $days ${days == 1 ? 'día' : 'días'}'),
              ]),
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label: 'Vida útil restante de la contraseña: $days de $lifeDays días',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: remaining,
                  minHeight: 8,
                  color: color,
                  backgroundColor: AppColors.surfaceHighest,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Las contraseñas duran $lifeDays días. Se avisa desde '
              '${User.passwordWarningDays} días antes; al vencer, el sistema '
              'pide cambiarla antes de cualquier otra acción.',
              style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onChangePassword,
              icon: const Icon(Icons.key_outlined, size: 18),
              label: const Text('Cambiar contraseña'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Una política de contraseñas con su explicación completa.
class _Policy {
  final IconData icon;
  final String title;
  final String summary;
  final String concept;
  final List<String> rules;
  final List<(String, String)> invalid;
  final String? valid;

  const _Policy({
    required this.icon,
    required this.title,
    required this.summary,
    required this.concept,
    required this.rules,
    this.invalid = const [],
    this.valid,
  });
}

/// Las cuatro políticas de configuración de contraseñas y cómo las aplica el
/// sistema. Los ejemplos son los de docs/politica-contrasenas.md.
class _PolicyCard extends StatelessWidget {
  const _PolicyCard();

  static const _valid = 'Laboratorio#2026Ucb';

  static const _policies = [
    _Policy(
      icon: Icons.password,
      title: 'Complejidad',
      summary: 'Mayúscula, minúscula, número y símbolo. No puede ser común ni parecerse a su usuario o correo.',
      concept: 'Mezclar distintos tipos de caracteres multiplica las combinaciones posibles, '
          'así que la contraseña es mucho más difícil de adivinar o de probar por fuerza bruta.',
      rules: [
        'Al menos una letra mayúscula y una minúscula.',
        'Al menos un número.',
        'Al menos un símbolo de esta lista: ~ ! @ # \$ % ^ & * ( ) _ + { } " : ; \' [ ]',
        'No puede estar entre unas 20 000 contraseñas comunes.',
        'No puede tener solo números.',
        'No puede parecerse a su código de usuario ni a su correo.',
      ],
      invalid: [
        ('laboratorio#2026ucb', 'no tiene mayúsculas'),
        ('Laboratorio2026Ucb', 'no tiene símbolo'),
        ('Laboratorio-2026-Ucb', 'el guion (-) no cuenta como símbolo'),
      ],
      valid: _valid,
    ),
    _Policy(
      icon: Icons.straighten,
      title: 'Longitud',
      summary: 'Al menos 12 letras: con el número y el símbolo, 14 caracteres o más.',
      concept: 'Cada carácter extra hace crecer exponencialmente el tiempo que tarda un ataque '
          'de fuerza bruta. Una contraseña larga resiste más que una corta aunque use los mismos tipos de caracteres.',
      rules: [
        'Al menos 12 letras.',
        'Sumando el número y el símbolo obligatorios, el mínimo real es de 14 caracteres.',
      ],
      invalid: [
        ('Laborator#2026Uc', 'tiene 11 letras'),
        ('Password1234', 'menos de 12 letras, es común y no tiene símbolo'),
      ],
      valid: _valid,
    ),
    _Policy(
      icon: Icons.hourglass_bottom,
      title: 'Tiempo de vida útil',
      summary: 'Vence a los 90 días. Se avisa 7 días antes y al vencer hay que cambiarla.',
      concept: 'Cambiar la contraseña cada cierto tiempo limita cuánto le sirve a un atacante '
          'una contraseña filtrada o adivinada.',
      rules: [
        'Cada contraseña dura 90 días desde que se eligió.',
        'Desde 7 días antes, el sistema avisa al entrar y en Mi perfil.',
        'Al vencer, el servidor solo permite cambiarla o cerrar la sesión: no deja hacer nada más.',
        'Para cambiarla pide la contraseña actual y una nueva que cumpla las demás políticas.',
      ],
    ),
    _Policy(
      icon: Icons.history,
      title: 'Histórico',
      summary: 'No puede repetir la actual ni las 4 anteriores.',
      concept: 'Si se pudiera volver siempre a la misma contraseña, el vencimiento no serviría: '
          'el historial obliga a usar una realmente nueva.',
      rules: [
        'La contraseña nueva no puede ser igual a ninguna de las últimas 5 (la actual y las 4 anteriores).',
        'Una contraseña más antigua que esas sí se puede volver a usar.',
        'Del historial solo se guardan resúmenes cifrados (hashes), nunca las contraseñas.',
        'Se aplica en todo cambio: el propio, por vencimiento y con un enlace.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardTitle(icon: Icons.policy_outlined, text: 'Política de contraseñas'),
          const SizedBox(height: AppSpacing.xs),
          const Text('Toque una política para ver el detalle.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 560 ? 2 : 1;
            final width = (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final policy in _policies)
                  SizedBox(width: width, child: _PolicyTile(policy: policy)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _PolicyTile extends StatefulWidget {
  final _Policy policy;
  const _PolicyTile({required this.policy});

  @override
  State<_PolicyTile> createState() => _PolicyTileState();
}

class _PolicyTileState extends State<_PolicyTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final policy = widget.policy;
    return Semantics(
      button: true,
      label: '${policy.title}. Ver el detalle',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: () => _showPolicyDetail(context, policy),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: hovered ? AppColors.surfaceHighest : AppColors.background.withOpacity(0.35),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                  color: hovered ? AppColors.primary.withOpacity(0.4) : Colors.transparent),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(policy.icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(policy.title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(policy.summary,
                          style: const TextStyle(
                              fontSize: 12, height: 1.45, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right,
                    size: 20, color: hovered ? AppColors.textPrimary : AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hoja que sube desde abajo con la explicación completa de una política.
/// Se puede deslizar para leer y arrastrar hacia abajo para cerrarla.
void _showPolicyDetail(BuildContext context, _Policy policy) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surfaceHigh,
    constraints: const BoxConstraints(maxWidth: 640),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg + 4)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl),
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(policy.icon, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(policy.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SheetHeading('¿Qué es?'),
          Text(policy.concept,
              style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          const _SheetHeading('Cómo la aplica LabLend'),
          for (final rule in policy.rules)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(rule,
                        style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
          if (policy.invalid.isNotEmpty || policy.valid != null) ...[
            const SizedBox(height: AppSpacing.lg),
            const _SheetHeading('Ejemplos'),
            for (final (password, reason) in policy.invalid)
              _ExampleRow(password: password, note: reason, ok: false),
            if (policy.valid != null)
              _ExampleRow(password: policy.valid!, note: 'cumple todas las políticas', ok: true),
          ],
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Estas reglas las valida el servidor: no se pueden saltar desde la aplicación.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    ),
  );
}

class _SheetHeading extends StatelessWidget {
  final String text;
  const _SheetHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  final String password;
  final String note;
  final bool ok;
  const _ExampleRow({required this.password, required this.note, required this.ok});

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.success : AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.cancel, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(password,
              style: const TextStyle(
                  fontFamily: 'monospace', fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text('· $note',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
