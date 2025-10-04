import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../data/hive_service.dart';
import '../models/link_model.dart';
import '../models/webview_config.dart';

/// LinkController
/// - Manages links for a given App (by appId)
/// - Provides CRUD, search, and reactive lists for the UI
class LinkController extends GetxController {
  final String appId;

  LinkController(this.appId);

  final RxList<LinkModel> _all = <LinkModel>[].obs;
  final RxString _query = ''.obs;
  late final Box<LinkModel> _linksBox;
  final _uuid = const Uuid();

  /// Filtered list based on the active search query.
  List<LinkModel> get links {
    final q = _query.value.trim().toLowerCase();
    final list = _all.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // newest first
    if (q.isEmpty) return list;
    return list.where((l) {
      return l.title.toLowerCase().contains(q) || l.url.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _linksBox = Hive.box<LinkModel>(HiveService.linksBoxName);
    _loadAll();

    // Watch for box changes to keep in sync
    _linksBox.watch().listen((_) {
      _loadAll();
    });
  }

  void _loadAll() {
    final list = _linksBox.values.where((l) => l.appId == appId).toList();
    _all.assignAll(list);
  }

  void setSearch(String query) => _query.value = query;

  Future<void> addLink({
    required String title,
    required String url,
    required String colorHex,
    WebViewConfig? config,
  }) async {
    final now = DateTime.now();
    final item = LinkModel(
      id: _uuid.v4(),
      appId: appId,
      title: title,
      url: url,
      colorHex: colorHex,
      config: config ?? const WebViewConfig(),
      createdAt: now,
      updatedAt: now,
    );
    await _linksBox.put(item.id, item);
    _loadAll();
  }

  Future<void> updateLink(LinkModel link) async {
    final updated = link.copyWith(updatedAt: DateTime.now());
    await _linksBox.put(updated.id, updated);
    _loadAll();
  }

  Future<void> deleteLink(String id) async {
    await _linksBox.delete(id);
    _loadAll();
  }

  LinkModel? getById(String id) => _linksBox.get(id);

  /// Update the lastUrl for a link (e.g., from WebView onUrlChanged)
  Future<void> updateLastUrl(String id, String lastUrl) async {
    final item = _linksBox.get(id);
    if (item == null) return;
    final updated = item.copyWith(lastUrl: lastUrl, updatedAt: DateTime.now());
    await _linksBox.put(id, updated);
    _loadAll();
  }
}
