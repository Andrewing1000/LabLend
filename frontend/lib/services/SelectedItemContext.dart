import 'package:flutter/foundation.dart';
import 'package:frontend/screens/PageContainer.dart';

import '../models/item.dart';

class SelectedItemContext extends ChangeNotifier{
  Item? _item;
  Item? get item => _item;

  bool isSet(){
    return _item != null;
  }
  void setItem(Item item){
    _item = item;
    notifyListeners();
  }
  void unsetItem(){
    _item = null;
    notifyListeners();
  }
}