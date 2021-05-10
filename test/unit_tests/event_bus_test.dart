import 'package:flutter_test/flutter_test.dart';
import 'package:sil_misc/sil_event_bus.dart';

void main() {
  group('Eventbus', () {
    test('should instantiate SILEventBus', () {
      final SILEventBus eventBus = SILEventBus();
      expect(eventBus, isA<SILEventBus>());

      expect(() => eventBus.destroy(), returnsNormally);
    });
  });
}
