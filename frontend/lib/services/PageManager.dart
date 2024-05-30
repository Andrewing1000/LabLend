import 'package:flutter/foundation.dart';
import 'package:frontend/screens/PageBase.dart';

class PageManager extends ChangeNotifier{
  PageBase defaultPage;
  PageBase focusedPage;
}