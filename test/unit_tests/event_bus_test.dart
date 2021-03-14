import 'package:flutter_test/flutter_test.dart';
import 'package:sil_misc/sil_event_bus.dart';

void main() {
  group('Eventbus', () {
    test('should instantiate SILEventBus', () {
      final SILEventBus eventBus = SILEventBus();
      expect(eventBus, isA<SILEventBus>());

      final Stream<dynamic> s1 = eventBus.on<dynamic>();
      expect(s1, isA<Stream<dynamic>>());

      final Stream<bool> s2 = eventBus.on<bool>();
      expect(s2, isA<Stream<bool>>());

      expect(() => eventBus.destroy(), returnsNormally);
    });
  });
}
