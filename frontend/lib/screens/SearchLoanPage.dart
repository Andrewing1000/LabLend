import 'package:frontend/themes/AppTheme.dart';
import 'package:frontend/widgets/state_message.dart';
import 'package:frontend/models/Permissions.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/LoanCard.dart';
import 'package:frontend/widgets/ReviewLoan.dart';
import '../models/Loan.dart';
import '../services/fechas.dart';

class SearchLoanPage extends BrowsablePage {

  ReturnedFilter returnedFilter = ReturnedFilter();
  DateFilter fromDateFilter = DateFilter(attributeName: "Desde");
  DateFilter toDateFilter = DateFilter(attributeName: "Hasta");

  SearchLoanPage({super.key}) : super(searchHint: 'Buscar por correo del usuario') {
    filterSet.add(returnedFilter);
    filterSet.add(fromDateFilter);
    filterSet.add(toDateFilter);
    //disposable = true;
  }

  @override
  void onSet(){
    // Buscar entre los préstamos de todos solo tiene sentido si puede
    // verlos (D17).
    searchEnabled = SessionManager().session.user
        .can(AppPermission.verTodosPrestamos);
    // Al volver a la página (por ejemplo, después de prestar) se pide de nuevo.
    _invalidate();
  }

  @override
  void onDispose() async {
    return;
  }

  Future<List<Loan>> _fetchItems(String? pattern) async {

    bool? isReturned;
    if(returnedFilter.getSelected().isNotEmpty){
      isReturned = returnedFilter.getSelected().first == "Devuelto";
    }

    var startDate = fromDateFilter.getSelected();
    var endDate = toDateFilter.getSelected();

    return await SessionManager.loanService.getLoanList(
      email: pattern,
      devuelto: isReturned,
      startDate: startDate.isNotEmpty? startDate.first: null,
      endDate: endDate.isNotEmpty? endDate.first: null,
    );
  }

  // La lista se guarda mientras no cambien la búsqueda ni los filtros, para
  // no pedirla al servidor cada vez que la pantalla se redibuja.
  String? _cacheKey;
  Future<List<Loan>>? _cache;

  Future<List<Loan>> _loans(String? pattern) {
    final key = [
      pattern ?? '',
      returnedFilter.getSelected().join(','),
      fromDateFilter.getSelected().join(','),
      toDateFilter.getSelected().join(','),
    ].join('|');
    if (key != _cacheKey || _cache == null) {
      _cacheKey = key;
      _cache = _fetchItems(pattern);
    }
    return _cache!;
  }

  void _invalidate() {
    _cacheKey = null;
    _cache = null;
  }

  @override
  Widget build(BuildContext context, SearchField searchField, FilterList filters, Widget? child) {
    final pattern = searchField.value.isNotEmpty ? searchField.value : null;

    void retry() {
      _invalidate();
      searchField.value = searchField.value;
    }

    return FutureBuilder<List<Loan>>(
      future: _loans(pattern),
      builder: (BuildContext context, AsyncSnapshot<List<Loan>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }
        if (snapshot.hasError) {
          return StateMessage.error(onAction: retry);
        }
        final loans = snapshot.data ?? <Loan>[];
        if (loans.isEmpty) {
          return StateMessage.emptyOrOffline(
            title: 'No se encontraron préstamos',
            icon: Icons.swap_horiz,
            onRetry: retry,
          );
        }
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
              sliver: SliverToBoxAdapter(child: _LoansSummary(loans: loans)),
            ),
            if (!AppBreakpoints.isCompact(context))
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xs),
                sliver: SliverToBoxAdapter(child: _LoansHeader()),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 110),
              sliver: SliverList.builder(
                itemCount: loans.length,
                itemBuilder: (context, index) => LoanCard(
                  loan: loans[index],
                  onTap: () => _showLoanDetail(context, loans[index], retry),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLoanDetail(BuildContext context, Loan loan, VoidCallback refresh) async {
    final wasReturned = loan.devuelto;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: Reviewloan(loan: loan),
      ),
    );
    // Si se marcó como devuelto, la lista (y sus filtros) se actualiza.
    if (loan.devuelto != wasReturned) refresh();
  }
}

/// Total de préstamos y cuántos están en curso, vencidos o devueltos.
class _LoansSummary extends StatelessWidget {
  final List<Loan> loans;
  const _LoansSummary({required this.loans});

  @override
  Widget build(BuildContext context) {
    int count(LoanStatus status) => loans.where((l) => LoanStatus.of(l) == status).length;
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '${loans.length}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: loans.length == 1 ? '  préstamo' : '  préstamos',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ]),
          style: TextStyle(color: AppColors.textPrimary),
        ),
        for (final status in [LoanStatus.active, LoanStatus.overdue, LoanStatus.returned])
          if (count(status) > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppSpacing.xs + 2),
                Text('${count(status)} ${status.label.toLowerCase()}',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
      ],
    );
  }
}

/// Títulos de las columnas, alineados con [LoanCard].
class _LoansHeader extends StatelessWidget {
  const _LoansHeader();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 12,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w700,
      color: AppColors.textMuted,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(flex: LoanCard.userFlex, child: Text('USUARIO', style: style)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(flex: LoanCard.datesFlex, child: Text('PRESTADO  →  DEVOLVER', style: style)),
          SizedBox(width: LoanCard.statusWidth, child: Text('ESTADO', style: style)),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}

class ReturnedFilter extends SingleFilter<String> {
  ReturnedFilter() : super(attributeName: "Estado");

  @override
  String getRepresentation(String item) {
    return item;
  }

  @override
  Future<List<String>> retrieveItems() async {
    return ["Devuelto", "Pendiente"];
  }
}

