import 'dart:async';

class SILEventBus {
  SILEventBus({bool sync = false})
      : _streamController = StreamController<dynamic>.broadcast(sync: sync);
  final StreamController<dynamic> _streamController;

  StreamController<dynamic> get streamController => _streamController;

  Stream<T> on<T>() {
    if (T == dynamic) {
      return streamController.stream as Stream<T>;
    } else {
      return streamController.stream
          .where((dynamic event) => event is T)
          .cast<T>();
    }
  }

  Future<void> fire(dynamic event) async {
    streamController.add(event);
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
