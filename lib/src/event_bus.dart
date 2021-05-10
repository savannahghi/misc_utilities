import 'dart:async';

class SILEventBus {
  SILEventBus({bool sync = false})
      : _streamController = StreamController<dynamic>.broadcast(sync: sync);
  final StreamController<dynamic> _streamController;

  StreamController<dynamic> get streamController => _streamController;

  Future<void> fire(dynamic event) async {
    _streamController.add(event);
  }

  void destroy() {
    _streamController.close();
  }
}

class TriggeredEvent {
  TriggeredEvent(
    this.eventName,
    this.eventPayload,
  );
  String eventName;
  Map<String, dynamic> eventPayload;
}
