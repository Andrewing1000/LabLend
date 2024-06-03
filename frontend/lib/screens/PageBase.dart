import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/Session.dart';
import '../services/PageManager.dart';

abstract class PageBase extends StatefulWidget {
  PageManager? manager;
  final Widget? child;
  final bool disposable;

  PageBase({
    Key? key,
    this.manager,
    this.child,
    this.disposable = false}):
  super(key: key);

  void onDispose();
  void onSet();
}

abstract class BrowsablePage extends PageBase {
  bool searchEnabled;
  final SearchField searchField = SearchField();
  final FilterList filterSet = FilterList();

  BrowsablePage({
    super.key,
    this.searchEnabled = true,
    super.manager,
    List<Filter> filters = const [],
  }) {
    for (Filter filter in filters) {
      this.filterSet.add(filter);
    }
  }

  @override
  State<BrowsablePage> createState(){
    return BrowsablePageState();
  }

  Widget build(BuildContext context, SearchField searchField, FilterList filters, Widget? child);
}

class BrowsablePageState extends State<BrowsablePage>{

  @override
  Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: widget.searchField),
          ChangeNotifierProvider.value(value: widget.filterSet),
        ],
        child: Consumer2<SearchField, FilterList>(
          builder: (context, searchField, filters, child) {
            return widget.build(context, searchField, filters, child);
          },
        ),
      );
    }
}


class SearchField extends ChangeNotifier {
  String _value = '';

  String get value => _value;

  set value(String value) {
    _value = value;
    notifyListeners();
  }
}

abstract class Filter<T> extends ChangeNotifier {
  List<T> _items;
  Set<T> _selected = {};
  final String attributeName;
  final bool multiple;
  final List<FilterList> _listListeners = [];

  Filter({
    required this.attributeName,
    List<T>? items = null,
    required this.multiple,
    Set<T>? selected,
  }):
    _items = items?? <T>[],
    _selected = selected?? <T>{};

  List<T> get items => _items;

  Future<List<T>> getItems() async {
    _items = await retrieveItems();
    for (T item in _selected) {
      if (!items.contains(item)) {
        deselect(item);
      }
    }
    //notifyListListeners();
    //notifyListeners();
    return items;
  }

  void select(T item) {
    if (!multiple && _selected.isNotEmpty) {
      _selected.clear();
    }
    if (items.contains(item)) {
      _selected.add(item);
    }
    notifyListListeners();
    notifyListeners();
  }

  void deselect(T item) {
    _selected.remove(item);
    notifyListListeners();
    notifyListeners();
  }

  void clearSelected() {
    _selected.clear();
    notifyListListeners();
    notifyListeners();
  }

  Set<T> getSelected() => _selected;

  bool isSelected(T item){
    return _selected.contains(item);
  }

  void addList(FilterList list) {
    _listListeners.add(list);
  }

  void removeList(FilterList list) {
    _listListeners.remove(list);
  }

  void notifyListListeners() {
    for (FilterList list in _listListeners) {
      list.notifyListenersBypass();
    }
  }

  Future<List<T>> retrieveItems();

  String getRepresentation(T item);
}

abstract class SingleFilter<T> extends Filter<T> {
  SingleFilter({
    required super.attributeName,
    super.items,
  }) : super(multiple: false);
}

abstract class MultipleFilter<T> extends Filter<T> {
  MultipleFilter({
    required super.attributeName,
    super.items,
  }) : super(multiple: true);
}

class DateFilter extends SingleFilter<DateTime>{
  DateFilter({required super.attributeName,});

  @override
  Future<List<DateTime>> retrieveItems() async {
    return [];
  }

  @override
  void select(DateTime item){
    clearSelected();
    _selected.add(item);

    notifyListListeners();
    notifyListeners();
  }

  @override
  String getRepresentation(DateTime item){
    return item.toIso8601String();
  }
}

class FilterList extends ChangeNotifier {
  final List<Filter> _filters = [];

  List<Filter> get filters => _filters;

  FilterList({List<Filter> filters = const []}) {
    for (Filter filter in filters) {
      add(filter);
    }
  }

  void add(Filter filter) {
    _filters.add(filter);
    filter.addList(this);
    notifyListeners();
  }

  void remove(Filter filter) {
    _filters.remove(filter);
    filter.removeList(this);
    notifyListeners();
  }

  void notifyListenersBypass() {
    notifyListeners();
  }
}
