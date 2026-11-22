import 'dart:async';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import 'package:visitapdv_app/core/services/connectivity_service.dart';
import '../../data/local/models/sync_queue_item.dart';
import '../../data/local/models/visita_hive_model.dart';

@lazySingleton
class SyncService {
  final ApiClient _apiClient;
  final ConnectivityService _connectivity;

  static const _boxName = 'sync_queue';
  static const _visitasBoxName = 'visitas';
  static const _maxRetries = 3;

  late Box<SyncQueueItem> _box;
  StreamSubscription<bool>? _connectivitySub;
  bool _syncing = false;

  SyncService(this._apiClient, this._connectivity);

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    _box = await Hive.openBox<SyncQueueItem>(_boxName);
    // Auto-sync cuando vuelve la conexión
    _connectivitySub = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) syncAll();
    });
    // Sync inicial si hay conexión
    if (_connectivity.isOnline) syncAll();
  }

  /// Encola una operación para sincronizar después.
  Future<void> enqueue(String operationType, Map<String, dynamic> payload) async {
    final item = SyncQueueItem()
      ..id            = const Uuid().v4()
      ..operationType = operationType
      ..payload       = payload
      ..createdAt     = DateTime.now()
      ..retryCount    = 0;
    await _box.put(item.id, item);

    if (_connectivity.isOnline) syncAll();
  }

  /// Procesa toda la cola pendiente.
  Future<void> syncAll() async {
    if (_syncing || _box.isEmpty) return;
    _syncing = true;

    try {
      final items = _box.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final item in items) {
        if (item.retryCount >= _maxRetries) continue;
        await _processItem(item);
      }
    } finally {
      _syncing = false;
    }
  }

  Future<void> _processItem(SyncQueueItem item) async {
    try {
      switch (item.operationType) {
        case 'iniciarVisita':
          await _apiClient.dio.post(ApiConstants.iniciarVisita, data: item.payload);
        case 'finalizarVisita':
          await _apiClient.dio.post(ApiConstants.finalizarVisita, data: item.payload);
      }
      // Éxito → eliminar de la cola y marcar local como sincronizado
      await _marcarSincronizado(item.payload['localId'] as String?);
      await item.delete();
    } catch (_) {
      item.retryCount++;
      await item.save();
    }
  }

  Future<void> _marcarSincronizado(String? localId) async {
    if (localId == null) return;
    if (!Hive.isBoxOpen(_visitasBoxName)) return;
    final box = Hive.box<VisitaHiveModel>(_visitasBoxName);
    final visita = box.get(localId);
    if (visita != null) {
      visita.sincronizado = true;
      await visita.save();
    }
  }

  int get pendingCount => _box.values
      .where((i) => i.retryCount < _maxRetries)
      .length;

  void dispose() {
    _connectivitySub?.cancel();
  }
}
