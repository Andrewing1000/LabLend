import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:frontend/models/Role.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/screens/create_user.dart';
import 'package:frontend/widgets/string_field.dart';
import 'package:frontend/widgets/user_form.dart';

/// Crear, modificar o eliminar un rol y elegir sus permisos (D15). Sin
/// rol, crea uno nuevo.
class RoleEditScreen extends PageBase {
  final Role? role;

  RoleEditScreen({super.key, this.role}) : super(disposable: true);

  @override
  RoleEditScreenState createState() => RoleEditScreenState();

  @override
  void onDispose() {}

  @override
  void onSet() {}
}

class RoleEditScreenState extends State<RoleEditScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<PermissionInfo> catalog = [];
  Set<String> selected = {};
  bool loading = true;
  bool saving = false;

  Role? get role => widget.role;
  bool get creating => role == null;

  /// El rol protegido (D27) y quien solo tiene ver_roles lo ven sin poder
  /// cambiarlo.
  bool get readOnly =>
      (role?.protected ?? false) ||
      !SessionManager().session.user.can(AppPermission.gestionarRoles);

  @override
  void initState() {
    super.initState();
    nameController.text = role?.name ?? '';
    descriptionController.text = role?.description ?? '';
    selected = Set.of(role?.permissions ?? const []);
    _loadCatalog();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    if (!loading) setState(() => loading = true);
    List<PermissionInfo> permissions = [];
    try {
      permissions = await SessionManager.roleService.getPermissions();
    } catch (_) {
      // Sin catálogo se muestra el aviso con "Reintentar" (antes la carga
      // quedaba girando para siempre si fallaba).
    }
    if (!mounted) return;
    setState(() {
      catalog = permissions;
      loading = false;
    });
  }

  /// Un rol con usuarios no gana ni pierde permisos de seguridad: el
  /// servidor lo rechaza, así que aquí esas casillas no se cambian.
  bool get securityLocked => !creating && role!.userCount > 0;

  /// Por qué no se puede cambiar un permiso, o null si se puede.
  String? _blockedReason(PermissionInfo permission) {
    if (readOnly) return null;
    final isSelected = selected.contains(permission.codename);
    if (permission.area == securityArea && securityLocked) {
      return 'El rol tiene usuarios: sus permisos de seguridad no cambian';
    }
    final area = selectedArea;
    // Un permiso ya marcado siempre se puede quitar, aunque el rol mezcle
    // áreas (antes quedaba bloqueado y no había forma de corregirlo).
    if (!isSelected && area != null && area != permission.area) {
      return 'No se combina con permisos de ${areaNames[area] ?? 'otra área'}';
    }
    return null;
  }

  /// Área de los permisos marcados: un rol no mezcla seguridad y
  /// laboratorio (D18).
  String? get selectedArea {
    for (final permission in catalog) {
      if (selected.contains(permission.codename)) return permission.area;
    }
    return null;
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      SessionManager().errorNotification(error: 'Ingrese el nombre del rol');
      return;
    }
    final confirmed = await SessionManager().confirmNotification(
        message: creating
            ? 'Se creará el rol "$name" con '
                '${_count(selected.length, 'permiso', 'permisos')}'
            : 'Se guardarán los cambios del rol "$name"'
                '${role!.userCount > 0 ? ': afectan a '
                    '${_count(role!.userCount, 'usuario', 'usuarios')} '
                    'desde su siguiente acción' : ''}');
    if (!confirmed || saving) return;

    final edited = Role(
      id: role?.id,
      name: name,
      description: descriptionController.text.trim(),
      permissions: selected.toList(),
    );
    setState(() => saving = true);
    Role? result;
    try {
      result = creating
          ? await SessionManager.roleService.createRole(edited)
          : await SessionManager.roleService.updateRole(edited);
    } finally {
      if (mounted) setState(() => saving = false);
    }
    if (result != null) widget.manager?.removePage();
  }

  String _count(int n, String one, String many) => '$n ${n == 1 ? one : many}';

  Future<void> _delete() async {
    if (saving) return;
    final confirmed = await SessionManager().confirmNotification(
        message: 'Se eliminará el rol "${role!.name}". Esta acción no se '
            'puede deshacer.');
    if (!confirmed) return;
    setState(() => saving = true);
    bool deleted = false;
    try {
      deleted = await SessionManager.roleService.deleteRole(role!);
    } finally {
      if (mounted) setState(() => saving = false);
    }
    if (deleted) widget.manager?.removePage();
  }

  static String _readable(String name) =>
      name.replaceAllMapped(RegExp(r'(?<=[a-záéíóúñ])(?=[A-ZÁÉÍÓÚÑ])'), (_) => ' ');

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    final canDelete = !readOnly && !creating;
    final hasUsers = !creating && role!.userCount > 0;

    final String subtitle;
    if (creating) {
      subtitle = 'Defina el nombre del rol y elija sus permisos.';
    } else if (readOnly) {
      subtitle = 'Consulte los permisos de este rol.';
    } else {
      subtitle = 'Modifique el rol y sus permisos.';
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                icon: Icons.badge_outlined,
                title: creating ? 'Nuevo rol' : _readable(role!.name),
                subtitle: subtitle,
              ),
              if (role?.protected ?? false)
                const _Note(
                    'El rol de administrador de seguridad está protegido: '
                    'no se modifica ni se elimina, y siempre tiene todos '
                    'los permisos de seguridad.'),
              if (!(role?.protected ?? false) &&
                  !SessionManager().session.user.can(AppPermission.gestionarRoles))
                const _Note('No tiene permiso para modificar roles.'),
              if (hasUsers)
                _Note(role!.userCount == 1
                    ? '1 usuario tiene este rol. Los cambios le afectan desde su '
                        'siguiente acción; para eliminar el rol, quíteselo antes.'
                    : '${role!.userCount} usuarios tienen este rol. Los cambios '
                        'les afectan desde su siguiente acción; para eliminar el '
                        'rol, quíteselo antes a cada uno.'),

              FormSection(
                title: 'Datos del rol',
                children: [
                  StringField(
                    controller: nameController,
                    enabled: !readOnly,
                    hintText: 'Inventario',
                    labelText: 'Nombre',
                    width: double.infinity,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  StringField(
                    controller: descriptionController,
                    enabled: !readOnly,
                    required: false,
                    hintText: 'Qué hace quien tiene este rol',
                    labelText: 'Descripción (opcional)',
                    width: double.infinity,
                  ),
                ],
              ),

              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: _InlineLoading(),
                )
              else if (catalog.isEmpty)
                FormSection(
                  title: 'Permisos',
                  children: [
                    Text('No se pudo cargar el catálogo de permisos.',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: _loadCatalog,
                        child: const Text('Reintentar'),
                      ),
                    ),
                  ],
                )
              else ...[
                if (!readOnly)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Text(
                      'Un rol no combina permisos de seguridad y de laboratorio '
                      '(segregación de funciones).',
                      style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                    ),
                  ),
                for (final area in [securityArea, labArea])
                  if (catalog.any((p) => p.area == area)) _permissionGroup(area),
              ],

              const SizedBox(height: AppSpacing.sm),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  if (canDelete)
                    _withTooltip(
                      hasUsers ? 'Quite el rol a sus usuarios antes de eliminarlo' : null,
                      TextButton(
                        onPressed: saving || hasUsers ? null : _delete,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          disabledForegroundColor: AppColors.textMuted,
                          minimumSize: const Size(0, 48),
                        ),
                        child: const Text('Eliminar rol'),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      OutlinedButton(
                        onPressed: saving ? null : () => widget.manager?.removePage(),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(140, 48)),
                        child: Text(readOnly ? 'Volver' : 'Cancelar'),
                      ),
                      if (!readOnly)
                        FilledButton(
                          onPressed: saving || loading ? null : _save,
                          style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
                          child: saving
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.onPrimary),
                                )
                              : Text(creating ? 'Crear rol' : 'Guardar cambios'),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _withTooltip(String? message, Widget child) =>
      message == null ? child : Tooltip(message: message, child: child);

  Widget _permissionGroup(String area) {
    final permissions = catalog.where((p) => p.area == area).toList();
    final count = permissions.where((p) => selected.contains(p.codename)).length;
    final title = 'Permisos de ${(areaNames[area] ?? area).toLowerCase()}';

    return FormSection(
      title: count > 0 ? '$title  ·  $count' : title,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 560 ? 2 : 1;
          final width = (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;
          return Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final permission in permissions)
                SizedBox(
                  width: width,
                  child: _PermissionTile(
                    permission: permission,
                    selected: selected.contains(permission.codename),
                    enabled: !readOnly && _blockedReason(permission) == null,
                    // En solo lectura no se atenúa: se está consultando.
                    dimmed: !readOnly && _blockedReason(permission) != null,
                    blockedReason: _blockedReason(permission),
                    onTap: () => setState(() {
                      selected.contains(permission.codename)
                          ? selected.remove(permission.codename)
                          : selected.add(permission.codename);
                    }),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}

/// Indicador de carga dentro del formulario.
class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, semanticsLabel: 'Cargando'),
      ),
    );
  }
}

/// Casilla de un permiso: nombre y código, o por qué no se puede elegir.
class _PermissionTile extends StatelessWidget {
  final PermissionInfo permission;
  final bool selected;
  final bool enabled;
  final bool dimmed;
  final String? blockedReason;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.permission,
    required this.selected,
    required this.enabled,
    required this.dimmed,
    required this.blockedReason,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      enabled: enabled,
      label: permission.name,
      hint: blockedReason,
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: selected ? AppColors.textSecondary : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 18,
                    color: selected ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(permission.name,
                          style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        blockedReason ?? permission.codename,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          fontFamily: blockedReason == null ? 'monospace' : null,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nota aclaratoria: texto en tono secundario, sin caja ni color.
class _Note extends StatelessWidget {
  final String text;

  const _Note(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Text(text,
          style: TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary)),
    );
  }
}
