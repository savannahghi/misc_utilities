// todo: move to `sil_core_domain_objects`
class SILException implements Exception {
  SILException({required this.cause, required this.message});
  final dynamic message;
  final dynamic cause;
}
