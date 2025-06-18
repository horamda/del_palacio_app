import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/aviso.dart';
import '../data/avisos_repository.dart';

final avisosRepositoryProvider = Provider<AvisosRepository>((ref) {
  return AvisosRepository();
});

final avisosProvider = FutureProvider.family<List<Aviso>, String>((ref, dni) async {
  final repository = ref.watch(avisosRepositoryProvider);
  return repository.getAvisos(dni);
});
