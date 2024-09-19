import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';

void downloadFileFromBase64(String base64Data, String fileName) {
  final bytes = base64.decode(base64Data);
  final blob = html.Blob([Uint8List.fromList(bytes)]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}