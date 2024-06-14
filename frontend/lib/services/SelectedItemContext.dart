import 'package:flutter/foundation.dart';

import '../models/Item.dart';

class SelectedItemContext extends ChangeNotifier{
  Item? _item;
  Item? get item => _item;

  bool isSet(){
    return _item != null;
  }
  void setItem(Item item){
    unsetItem();
    _item = item;
    item.addListener((){
      notifyListeners();
    });
    notifyListeners();
  }
  void unsetItem(){
    if(_item != null ){
      _item?.removeListener(notifyListeners);
    }
    _item = null;
    notifyListeners();
  }
}