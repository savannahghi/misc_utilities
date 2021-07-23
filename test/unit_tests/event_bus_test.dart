import 'package:flutter_test/flutter_test.dart';
import 'package:misc_utilities/event_bus.dart';

void main() {
  group('EventBus', () {
    test('should instantiate EventBus', () {
      final EventBus eventBus = EventBus();
      expect(eventBus, isA<EventBus>());

      expect(() => eventBus.destroy(), returnsNormally);
    });
  });
}
