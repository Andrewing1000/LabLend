import 'package:frontend/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:frontend/models/Role.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/banner.dart';
import 'package:frontend/widgets/boton_agregar.dart';
import 'package:frontend/widgets/string_field.dart';

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
    final permissions = await SessionManager.roleService.getPermissions();
    if (!mounted) return;
    setState(() {
      catalog = permissions;
      loading = false;
    });
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
    if (!confirmed) return;

    final edited = Role(
      id: role?.id,
      name: name,
      description: descriptionController.text.trim(),
      permissions: selected.toList(),
    );
    final result = creating
        ? await SessionManager.roleService.createRole(edited)
        : await SessionManager.roleService.updateRole(edited);
    if (result != null) widget.manager?.removePage();
  }

  String _count(int n, String one, String many) => '$n ${n == 1 ? one : many}';

  Future<void> _delete() async {
    final confirmed = await SessionManager().confirmNotification(
        message: 'Se eliminará el rol "${role!.name}"');
    if (!confirmed) return;
    if (await SessionManager.roleService.deleteRole(role!)) {
      widget.manager?.removePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldWidth = MediaQuery.of(context).size.width * 0.8;
    final canManage =
        SessionManager().session.user.can(AppPermission.gestionarRoles);

    return SingleChildScrollView(
      child: Column(
        children: [
          BannerWidget(
              imageUrl: null,
              title: creating ? 'Nuevo rol' : 'Rol ${role!.name}',
              subtitle: '',
              description: ''),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (role?.protected ?? false)
                  const _Note(
                      'El rol de administrador de seguridad está protegido: '
                      'no se modifica ni se elimina, y siempre tiene todos '
                      'los permisos de seguridad.'),
                if (!creating && role!.userCount > 0)
                  _Note(role!.userCount == 1
                      ? '1 usuario tiene este rol. Para eliminarlo, '
                          'quíteselo antes.'
                      : '${role!.userCount} usuarios tienen este rol. Para '
                          'eliminarlo, quíteselo antes a cada uno.'),
                StringField(
                  controller: nameController,
                  enabled: !readOnly,
                  hintText: 'Inventario',
                  labelText: 'Nombre',
                  width: fieldWidth,
                ),
                const SizedBox(height: 20),
                StringField(
                  controller: descriptionController,
                  enabled: !readOnly,
                  required: false,
                  hintText: 'Qué hace quien tiene este rol',
                  labelText: 'Descripción',
                  width: fieldWidth,
                ),
                const SizedBox(height: 20),
                const Text('Permisos',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
                const Text(
                    'Un rol no combina permisos de seguridad y de '
                    'laboratorio. Un rol con usuarios no puede ganar ni '
                    'perder permisos de seguridad.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 10),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.textPrimary),
                  )
                else
                  for (final area in [securityArea, labArea])
                    ..._permissionGroup(area),
                const SizedBox(height: 20),
                if (!readOnly)
                  Row(
                    children: [
                      BotonAgregar(
                        icon: creating ? Icons.add : Icons.save,
                        onPressed: _save,
                      ),
                      const SizedBox(width: 20),
                      if (!creating && canManage)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          label: const Text('Eliminar rol',
                              style: TextStyle(color: AppColors.error)),
                          onPressed: _delete,
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

  List<Widget> _permissionGroup(String area) {
    final permissions = catalog.where((p) => p.area == area).toList();
    final otherArea = selectedArea != null && selectedArea != area;
    return [
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(areaNames[area] ?? area,
            style: const TextStyle(color: AppColors.primary, fontSize: 16)),
      ),
      for (final permission in permissions)
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          checkColor: AppColors.background,
          value: selected.contains(permission.codename),
          title: Text(permission.name,
              style: TextStyle(
                  color: otherArea ? AppColors.textMuted : AppColors.textPrimary)),
          subtitle: Text(permission.codename,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          onChanged: readOnly || otherArea
              ? null
              : (value) => setState(() {
                    value == true
                        ? selected.add(permission.codename)
                        : selected.remove(permission.codename);
                  }),
        ),
    ];
  }
}

class _Note extends StatelessWidget {
  final String text;

  const _Note(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }
}
