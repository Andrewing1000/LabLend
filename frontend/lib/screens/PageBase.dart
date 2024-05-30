import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/Session.dart';
import '../services/PageManager.dart';

abstract class PageBase extends StatelessWidget{
  Session session;
  PageManager manager;
  Widget? child;
  PageBase({super.key, required this.session, required this.manager, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(child: child,);
  }



  // void discard(){
  //   manager.discard(this);
  // }
  //
  // void replace(PageBase page){
  //   manager.replace(page);
  // }

}

abstract class BrowsablePage extends PageBase{
  SearchField searchField = SearchField();
  FilterList filters = FilterList();
  Widget Function(BuildContext, SearchField, FilterList, Widget?) rebuild;
  BrowsablePage({super.key,
    required super.session,
    required super.manager,
    List<Filter> filters = const [],
    required this.rebuild,
  }){
    for(Filter filter in filters){
      this.filters.add(filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => searchField),
        ChangeNotifierProvider(create: (context)=> filters)],
      child: Consumer2<SearchField, FilterList>(
        builder: (context, SearchField searchField, FilterList filters, child){
          return rebuild(context, searchField, filters, child);
        },
      ),
    );
  }
}

class SearchField extends ChangeNotifier{
  String _value = '';
  SearchField();

  String get value => _value;
  set value(String value){
        _value = value;
        notifyListeners();
  }
}

abstract class Filter<T> extends ChangeNotifier{
  List<T> items;
  Set<T> selected;
  String attributeName;
  bool multiple;
  List<FilterList> _listListeners = [];

  Filter(
  {required this.attributeName,
   required this.items,
   required this.multiple,
   this.selected = const {}});

  List<T> getItems(){
    items = retrieveItems();
    for(T item in items){
      if(!items.contains(item)){
        deselect(item);
      }
    }

    notifyListeners();
    return items;
  }

  void select(T item){
    if(!multiple && selected.isNotEmpty){
      throw Exception('Just one item can be selected.');
      return;
    }
    if(items.contains(item)){
      selected.add(item);
    }
    notifyListListeners();
    notifyListeners();
  }

  void deselect(T item){
    selected.remove(item);
    notifyListListeners();
    notifyListeners();
  }


  void addList(FilterList list){
    _listListeners.add(list);
  }

  void removeList(FilterList list){
    _listListeners.remove(list);
  }

  void notifyListListeners(){
    for(FilterList list in _listListeners){
      list.notifyListenersBypass();
    }
  }

  List<T> retrieveItems();
  String getRepresentation(T item);
}


abstract class SingleFilter<T> extends Filter<T>{
   SingleFilter({required super.attributeName, required super.items}): super(multiple: false);
}

abstract class MultipleFilter<T> extends Filter<T>{
  MultipleFilter({required super.attributeName, required super.items}): super(multiple: true);
}

class FilterList extends ChangeNotifier{
  List<Filter> _filters = [];
  FilterList({List<Filter> filters = const []}){
   for(Filter filter in filters){
     add(filter);
   }
  }

  void add(Filter filter){
    _filters.add(filter);
    filter.addList(this);
    notifyListeners();
  }

  void remove(Filter filter){
    _filters.remove(filter);
    filter.removeList(this);
    notifyListeners();
  }

  void notifyListenersBypass(){
    notifyListeners();
  }
}


