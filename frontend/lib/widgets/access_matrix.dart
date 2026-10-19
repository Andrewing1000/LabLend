import 'package:flutter/material.dart';
import 'package:frontend/models/Role.dart';

/// Matriz de accesos (D19): qué permiso tiene cada rol, con los datos del
/// servidor. Incluye los roles creados desde la aplicación, así que siempre
/// coincide con lo que el servidor permite.
class AccessMatrix extends StatelessWidget {
  final List<Role> roles;
  final List<PermissionInfo> permissions;

  const AccessMatrix(
      {super.key, required this.roles, required this.permissions});

  static const double _functionWidth = 210;

  static const _header = TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13);

  @override
  Widget build(BuildContext context) {
    final rows = <DataRow>[];
    for (final area in [securityArea, labArea]) {
      final inArea = permissions.where((p) => p.area == area);
      if (inArea.isEmpty) continue;
      rows.add(DataRow(
        color: WidgetStateProperty.all(Colors.white10),
        cells: [
          DataCell(Text(areaNames[area] ?? area,
              style: const TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold))),
          for (final _ in roles) const DataCell(SizedBox.shrink()),
        ],
      ));
      for (final permission in inArea) {
        rows.add(DataRow(cells: [
          DataCell(SizedBox(
            width: _functionWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(permission.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 12)),
                Text(permission.codename,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          )),
          for (final role in roles)
            DataCell(Center(
              child: role.permissions.contains(permission.codename)
                  ? const Icon(Icons.check_circle,
                      color: Colors.orange, size: 20,
                      semanticLabel: 'Sí')
                  : const Text('—', style: TextStyle(color: Colors.white24)),
            )),
        ]));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // Nombres de rol en vertical: así caben varias columnas aunque
            // el panel sea angosto.
            child: DataTable(
              dataRowMinHeight: 52,
              dataRowMaxHeight: 64,
              headingRowHeight: 190,
              columnSpacing: 14,
              horizontalMargin: 12,
              headingRowColor: WidgetStateProperty.all(Colors.black),
              border: TableBorder.all(color: Colors.white12),
              columns: [
                const DataColumn(
                  label: Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('Función', style: _header),
                      ),
                    ),
                  ),
                ),
                for (final role in roles)
                  DataColumn(
                    tooltip: role.description.isEmpty ? null : role.description,
                    label: RotatedBox(
                      quarterTurns: 3,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(role.name, style: _header),
                          if (role.protected) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.lock,
                                size: 14, color: Colors.orange),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
              rows: rows,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin sesión (visitante): solo consulta el catálogo de equipos. '
            'Toda cuenta, con cualquier rol, ve y edita su perfil y cambia '
            'su contraseña.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
