import 'dart:io';

void main() {
  final dir = Directory('assets/images/visual_guides');
  final regex = RegExp(r'<rect[^>]*fill="(?:#000|black)"[^>]*/>');
  for (var file in dir.listSync()) {
    if (file is File && file.path.endsWith('.svg')) {
      final content = file.readAsStringSync();
      final newContent = content.replaceAll(regex, '');
      file.writeAsStringSync(newContent);
    }
  }
}
