import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/screens/PageBase.dart';

class PageManager extends ChangeNotifier{

  static int maxLength = 10;
  Queue<PageBase> lastQueue = Queue();
  Queue<PageBase> nextQueue = Queue();

  PageBase defaultPage;

  PageManager({required this.defaultPage}){
    defaultPage.manager = this;
    lastQueue.addLast(defaultPage);
  }

  PageBase get currentPage => lastQueue.last;
  bool get isNextAvailable => nextQueue.isNotEmpty;
  bool get isLastAvailable => lastQueue.length > 1;

  void disposePage(){
    if(!isLastAvailable){
      return;
    }

    if(currentPage.disposable){
      lastQueue.last.onDispose();
      lastQueue.removeLast();
    }
  }


  void toDefault(){
    setPage(defaultPage);
  }

  void toNext(){
    if(!isNextAvailable){
      return;
    }
    disposePage();
    lastQueue.addLast(nextQueue.first);
    nextQueue.removeFirst();
    currentPage.onSet();
    notifyListeners();
  }

  void toLast(){
    if(!isLastAvailable){
      return;
    }
    if(currentPage.disposable){
      disposePage();
      return;
    }

    nextQueue.addFirst(lastQueue.last);
    lastQueue.removeLast();
    currentPage.onSet();
    notifyListeners();
  }

  void setPage(PageBase page){
    if(page == currentPage){
      return;
    }
    disposePage();
    page.manager = this;
    if(isNextAvailable){
      if(nextQueue.first == page){
        toNext();
        return;
      }
    }

    nextQueue.clear();
    lastQueue.addLast(page);
    while(lastQueue.length > PageManager.maxLength){
      lastQueue.removeFirst();
    }
    currentPage.onSet();
    notifyListeners();
  }

  void removePage(){
    if(!isLastAvailable){
      return;
    }
    lastQueue.last.onDispose();
    lastQueue.removeLast();
    currentPage.onSet();
    notifyListeners();
  }

  void replacePage(PageBase page){
    if(page == currentPage){
      return;
    }
    if(!isLastAvailable){
      return;
    }

    lastQueue.last.onDispose();
    lastQueue.removeLast();
    lastQueue.addLast(page);
    currentPage.onSet();
    notifyListeners();
  }
}
