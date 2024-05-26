import 'package:flutter/cupertino.dart';

abstract class FrameAdapter{
  Widget? mainFrame;

  setUpFrame(Widget mainFrame);
}

class VisitorFrameAdapter extends FrameAdapter{
  @override
  setUpFrame(Widget mainFrame) {

  }
}


class AdminFrameAdapter extends FrameAdapter{
  @override
  setUpFrame(Widget mainFrame) {


  }
}



class AssistantFrameAdapter extends FrameAdapter{
  @override
  setUpFrame(Widget mainFrame) {


  }
}