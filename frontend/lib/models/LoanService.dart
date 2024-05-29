import 'Session.dart';
import 'Loan.dart';
import 'package:dio/dio.dart';

class LoanService {

  static var manager = SessionManager();
  var session = SessionManager.session;
  var requestHandler;

  LoanService(this.requestHandler) {
    requestHandler = session.requestHandler;
  }

  Future<List<Loan>> getLoanList({DateTime? startDate, DateTime? endDate, bool? devuelto}) async {
    if (!await isReady()) {
      return [];
    }
    if (!await sessionCheck()) {
      return [];
    }

    var response;
    try {
      // Build the query parameters
      Map<String, dynamic> queryParams = {};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T').first; // Extracting the date part
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T').first; // Extracting the date part
      }
      if (devuelto != null) {
        queryParams['devuelto'] = devuelto.toString();
      }

      // Convert the query parameters to a query string
      String queryString = Uri(queryParameters: queryParams).query;

      // Make the GET request with the query parameters
      response = await requestHandler.getRequest('/loan/loan/?$queryString');
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return [];
    }

    List<Loan> loanList = [];
    for (var loanData in response.data) {
      var loan = Loan.fromJson(loanData);
      loanList.add(loan);
    }

    return loanList;
  }


  Future<Loan> getLoan(int id) async {
    if (!await isReady()) {
      return Loan(
          id: 0,
          usuario: '',
          fechaPrestamo: DateTime.now(),
          fechaDevolucion: DateTime.now(),
          devuelto: false,
          items: []);
    }
    if (!await sessionCheck()) {
      return Loan(
          id: 0,
          usuario: '',
          fechaPrestamo: DateTime.now(),
          fechaDevolucion: DateTime.now(),
          devuelto: false,
          items: []);
    }

    var response;
    try {
      response = await requestHandler.getRequest('/loan/loan/$id/');
      return Loan.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: '', details: e.response?.data);
      return Loan(
          id: 0,
          usuario: '',
          fechaPrestamo: DateTime.now(),
          fechaDevolucion: DateTime.now(),
          devuelto: false,
          items: []);
    }
  }

  Future<Loan> createLoan(Loan loan) async {
    if (!await isReady()) {
      return Loan(
          id: 0,
          usuario: '',
          fechaPrestamo: DateTime.now(),
          fechaDevolucion: DateTime.now(),
          devuelto: false,
          items: []);
    }
    if (!await sessionCheck()) {
      return Loan(
          id: 0,
          usuario: '',
          fechaPrestamo: DateTime.now(),
          fechaDevolucion: DateTime.now(),
          devuelto: false,
          items: []);
    }

    try {
      var response = await requestHandler.postRequest('/loan/loan/', body: loan.toJson());
      manager.notification(notification: 'Préstamo creado con éxito');
      return Loan.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: 'Creación de préstamo fallida', details: e.response?.data);
      return Loan(
          id: 0,
          usuario: '',
          fechaPrestamo: DateTime.now(),
          fechaDevolucion: DateTime.now(),
          devuelto: false,
          items: []);
    }
  }

  Future<Loan> updateLoan(Loan loan, Loan newLoan) async {
    if (!await isReady()) {
      return loan;
    }
    if (!await sessionCheck()) {
      return loan;
    }

    try {
      var response = await requestHandler.putRequest('/loan/loan/${loan.id}/', body: newLoan.toJson());
      loan.updatePrestamo(newLoan);
      manager.notification(notification: 'Préstamo actualizado con éxito');
      return Loan.fromJson(response.data);
    } on DioException catch (e) {
      manager.errorNotification(error: 'Actualización de préstamo fallida', details: e.response?.data);
      return loan;
    }
  }

  Future<void> updateDevuelto(Loan loan, bool devuelto) async {
    if (!await isReady()) {
      return;
    }
    if (!await sessionCheck()) {
      return;
    }

    var updatedLoan = Loan(
      id: loan.id,
      usuario: loan.usuario,
      fechaPrestamo: loan.fechaPrestamo,
      fechaDevolucion: loan.fechaDevolucion,
      devuelto: devuelto,
      items: loan.items,
    );

    await updateLoan(loan, updatedLoan);
  }

  Future<bool> isReady() async {
    return await session.isReady();
  }

  sessionCheck() {
    return session.sessionCheck();
  }
}
