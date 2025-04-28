/// This file provides stub implementations of web-specific functionality
/// for use on mobile platforms

// File-related stubs
class File {
  // Stub methods and properties
}

class FileReader {
  dynamic get result => null;
  Stream<dynamic> get onLoad => const Stream.empty();
  void readAsDataUrl(dynamic _) {}
}

class FileUploadInputElement {
  String accept = '';
  List<File>? get files => null;
  Stream<dynamic> get onChange => const Stream.empty();
  void click() {}
}

// Image and canvas stubs
class ImageElement {
  String src = '';
  int width = 0;
  int height = 0;
  Stream<dynamic> get onLoad => const Stream.empty();
}

class CanvasElement {
  CanvasElement({this.width, this.height});
  int? width;
  int? height;
  CanvasRenderingContext2D get context2D => CanvasRenderingContext2D();
}

class CanvasRenderingContext2D {
  void drawImage(dynamic _, int __, int ___) {}
  ImageData getImageData(int _, int __, int ___, int ____) => ImageData();
}

class ImageData {
  List<int> data = [];
  int width = 0;
  int height = 0;
}

// DOM-related stubs
class Element {
  String id = '';
  void addEventListener(String _, Function __) {}
}

class DivElement extends Element {
  dynamic style = _ElementStyle();
}

class _ElementStyle {
  String width = '';
  String height = '';
}

class MouseEvent {
  DataTransfer? dataTransfer;
  void preventDefault() {}
  void stopPropagation() {}
}

class DataTransfer {
  List<File>? files;
}

// Document stub
final document = _Document();

class _Document {
  Element? getElementById(String _) => null;
  final body = _Body();
}

class _Body {
  List<Element> children = [];
  void add(Element _) {}
}

// JS context stub
final context = _Context();

class _Context {
  dynamic callMethod(String _, List<dynamic> __) {
    return null;
  }
}
