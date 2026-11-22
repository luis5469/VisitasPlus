import 'package:hive/hive.dart';

part 'sync_queue_item.g.dart';

/// Tipos de operación pendiente de sincronización.
enum SyncOperationType { iniciarVisita, finalizarVisita }

@HiveType(typeId: 12)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  late String id; // UUID local

  @HiveField(1)
  late String operationType; // 'iniciarVisita' | 'finalizarVisita'

  @HiveField(2)
  late Map<String, dynamic> payload;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  int retryCount = 0;

  @HiveField(5)
  String? errorMessage;
}
