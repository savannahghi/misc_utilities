import 'package:flutter_test/flutter_test.dart';
import 'package:misc_utilities/event_bus.dart';

void main() {
  group('EventBus', () {
    test('should instantiate SILEventBus', () {
      final SILEventBus eventBus = SILEventBus();
      expect(eventBus, isA<SILEventBus>());

      expect(() => eventBus.destroy(), returnsNormally);
    });
  });
}
