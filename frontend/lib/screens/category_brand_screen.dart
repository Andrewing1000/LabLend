import 'package:flutter/material.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/screens/create_user.dart' show PageHeader;
import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/category_brand_form.dart';

/// Gestión de las marcas y categorías con las que se clasifican los equipos.
class CategoryBrandScreen extends PageBase {
  CategoryBrandScreen({super.key});

  @override
  State<CategoryBrandScreen> createState() => _CategoryBrandScreenState();

  @override
  void onDispose() {
    return;
  }

  @override
  void onSet() {
    return;
  }
}

class _CategoryBrandScreenState extends State<CategoryBrandScreen> {
  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    final wide = AppBreakpoints.isWide(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          // Con pantalla ancha las dos listas van lado a lado.
          constraints: BoxConstraints(maxWidth: wide ? 1080 : 760),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                icon: Icons.category_outlined,
                title: 'Marcas y categorías',
                subtitle: 'Las opciones con las que se clasifican los equipos al registrarlos.',
              ),
              CategoryBrandForm(),
            ],
          ),
        ),
      ),
    );
  }
}
