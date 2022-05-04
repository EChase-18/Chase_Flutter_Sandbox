import 'dart:isolate';

class IsolateDataObject {
  final String jsonData;
  final SendPort newSendPort;

  IsolateDataObject({required this.jsonData, required this.newSendPort});
}
