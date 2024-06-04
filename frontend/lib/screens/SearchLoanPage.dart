import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/loan_card.dart';
import '../models/Loan.dart';
import '../models/User.dart';
import '../models/item.dart';

class SearchLoanPage extends BrowsablePage {
  ReturnedFilter returnedFilter = ReturnedFilter();
  DateFilter fromDateFilter = DateFilter(attributeName: "Desde");
  DateFilter toDateFilter = DateFilter(attributeName: "Hasta");

  SearchLoanPage({super.key}) {
    filterSet.add(returnedFilter);
    filterSet.add(fromDateFilter);
    filterSet.add(toDateFilter);
    //disposable = true;
  }

  @override
  void onSet() {
    Role role = SessionManager().session.user.role; // Acceder usuario actual
    searchEnabled = role == Role.adminRole;
  }

  @override
  void onDispose() async {
    return;
  }

  Future<List<Loan>> _fetchItems(String? pattern) async {
    bool? isReturned;
    if (returnedFilter.getSelected().isNotEmpty) {
      isReturned = returnedFilter.getSelected().first == "Devuelto";
    }

    var startDate = fromDateFilter.getSelected();
    var endDate = toDateFilter.getSelected();

    return await SessionManager.loanService.getLoanList(
      email: pattern,
      devuelto: isReturned,
      startDate: startDate.isNotEmpty ? startDate.first : null,
      endDate: endDate.isNotEmpty ? endDate.first : null,
    );
  }

  @override
  Widget build(BuildContext context, SearchField searchField,
      FilterList filters, Widget? child) {
    String? pattern;

    if (searchField.value.isNotEmpty) {
      pattern = searchField.value;
    }

    return FutureBuilder<List<Loan>>(
      future: _fetchItems(pattern),
      builder: (BuildContext context, AsyncSnapshot<List<Loan>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron préstamos',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          List<Loan> loans = snapshot.data!;
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(10.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400.0, // Maximum width of each item
                    mainAxisSpacing: 10.0, // Spacing between rows
                    crossAxisSpacing: 10.0, // Spacing between columns
                    childAspectRatio: 2.0, // Adjust this if needed
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      Loan loan = loans[index];
                      return FutureBuilder<Item?>(
                        future: SessionManager.inventory
                            .getItemById(loan.items.first.itemId),
                        builder: (context, itemSnapshot) {
                          if (itemSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white));
                          } else if (itemSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${itemSnapshot.error}'));
                          } else if (!itemSnapshot.hasData) {
                            return const Center(
                                child: Text('Item no encontrado',
                                    style: TextStyle(color: Colors.white)));
                          } else {
                            Item item = itemSnapshot.data!;
                            return LoanCard(
                              loan: loan,
                              item: item,
                              onReturn: () {
                                // Refresh the page after returning an item
                              },
                            );
                          }
                        },
                      );
                    },
                    childCount: loans.length, // Number of items in the grid
                  ),
                ),
              ),
            ],
          );
        }
      },
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

class DateFilter extends SingleFilter<DateTime> {
  DateFilter({required String attributeName})
      : super(attributeName: attributeName);

  @override
  String getRepresentation(DateTime item) {
    return item.toString();
  }

  @override
  Future<List<DateTime>> retrieveItems() async {
    // Return an empty list as this is just a filter by date range
    return [];
  }
}
