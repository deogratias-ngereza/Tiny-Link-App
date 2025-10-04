import 'package:get/get.dart';

import '../models/link_model.dart';

/// TabsController keeps track of currently opened browser tabs (links).
/// It's an in-memory list for the session. You can extend to persist if desired.
class TabsController extends GetxController {
  final RxList<LinkModel> _tabs = <LinkModel>[].obs;

  List<LinkModel> get tabs => _tabs.toList(growable: false);
  int get count => _tabs.length;

  void addOrActivate(LinkModel link) {
    final idx = _tabs.indexWhere((e) => e.id == link.id);
    if (idx == -1) {
      _tabs.add(link);
    } else {
      // Move to end to mark as most recently active
      final existing = _tabs.removeAt(idx);
      _tabs.add(existing);
    }
  }

  void closeTabById(String id) {
    _tabs.removeWhere((e) => e.id == id);
  }

  void closeAll() {
    _tabs.clear();
  }
}
