import 'package:flutter/rendering.dart';

void enableDebug(bool enable) {
  debugPaintSizeEnabled = enable;
  debugPaintPointersEnabled = enable;
  debugPaintBaselinesEnabled = enable;
  debugPaintLayerBordersEnabled = enable;
  debugRepaintRainbowEnabled = enable;
}

void toggleDebug() {
  debugPaintSizeEnabled = !debugPaintSizeEnabled;
  debugPaintPointersEnabled = !debugPaintPointersEnabled;
  debugPaintBaselinesEnabled = !debugPaintBaselinesEnabled;
  debugPaintLayerBordersEnabled = !debugPaintLayerBordersEnabled;
  debugRepaintRainbowEnabled = !debugRepaintRainbowEnabled;
}