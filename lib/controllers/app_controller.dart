import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../data/hive_service.dart';
import '../models/app_model.dart';

/// AppController
/// - Manages list of Apps (e.g., "YouTube", "Gmail") which group multiple links.
/// - Provides CRUD operations for apps.
/// - Exposes an observable list for UI to reactively update.
class AppController extends GetxController {
  final RxList<AppModel> apps = <AppModel>[].obs;
  final _uuid = const Uuid();

  late final Box<AppModel> _appsBox;

  @override
  void onInit() {
    super.onInit();
    _appsBox = Hive.box<AppModel>(HiveService.appsBoxName);

    // Initial load
    _loadApps();

    // Listen to hive box changes and refresh list
    _appsBox.watch().listen((_) {
      _loadApps();
    });
  }

  void _loadApps() {
    // Sort alphabetically for a stable UI
    final list = _appsBox.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    apps.assignAll(list);
  }

  Future<void> createApp({
    required String name,
    String colorHex = '#607D8B', // default blue grey
  }) async {
    final id = _uuid.v4();
    final app = AppModel(id: id, name: name, colorHex: colorHex);
    await _appsBox.put(id, app);
    _loadApps();
  }

  Future<void> updateApp(AppModel app) async {
    await _appsBox.put(app.id, app);
    _loadApps();
  }

  Future<void> deleteApp(String id) async {
    await _appsBox.delete(id);
    _loadApps();
  }

  AppModel? getById(String id) => _appsBox.get(id);
}
