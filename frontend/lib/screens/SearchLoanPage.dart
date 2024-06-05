import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:frontend/models/Session.dart';
import 'package:frontend/screens/PageBase.dart';
import 'package:frontend/widgets/LoanCard.dart';
import 'package:frontend/widgets/ReviewLoan.dart';
import 'package:frontend/widgets/card.dart';
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
  void onSet(){
    Role role = SessionManager().session.user.role; ///Acceder usuario actual
    searchEnabled = role == Role.adminRole;
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

  @override
  Widget build(BuildContext context, SearchField searchField, FilterList filters, Widget? child) {
    String? pattern;

    if (searchField.value.isNotEmpty) {
      pattern = searchField.value;
    }

    return FutureBuilder<List<Loan>>(
      future: _fetchItems(pattern),
      builder: (BuildContext context, AsyncSnapshot<List<Loan>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white,));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron items',
            style: TextStyle(color: Colors.white),));
        } else {
          List<Loan> items = snapshot.data!;
          return Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Colors.black,
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    )
                ),
                padding: const EdgeInsets.fromLTRB(40.0, 20, 40, 20),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Text(
                        'Usuario',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Text(
                        'Fecha Préstamo',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Text(
                        'Fecha Devolución',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Text(
                        'Estado',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.all(10.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index){
                            return LoanCard(loan: items[index], onTap: (){
                              _showLoanDetail(context, items[index]);
                            });
                          },
                          childCount: items.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  void _showLoanDetail(BuildContext context, Loan loan){
    showModalBottomSheet(context: context,
      backgroundColor: Colors.black,
      builder: (context){
        return Reviewloan(loan: loan);
      }
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

