import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/link_controller.dart';
import '../../data/hive_service.dart';
import '../../models/link_model.dart';
import '../../models/webview_config.dart';
import '../../routes/app_pages.dart';

/// LinksPage
/// - Displays and manages links for a given App (by appId).
/// - Features: search, add, edit, delete, open in webview.
class LinksPage extends StatefulWidget {
  final String appId;
  final String? appName;

  const LinksPage({super.key, required this.appId, this.appName});

  @override
  State<LinksPage> createState() => _LinksPageState();
}

class _LinksPageState extends State<LinksPage> {
  late final LinkController _controller;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use tag=appId so each app has its own controller instance.
    _controller = Get.put(LinkController(widget.appId), tag: widget.appId);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appName ?? 'Links'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              await _showSearchSheet(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        final items = _controller.links;
        if (items.isEmpty) {
          return _EmptyLinks(appName: widget.appName);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final l = items[index];
            final color = Color(HiveService.parseColorHex(l.colorHex));
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(Icons.link, color: color),
                ),
                title: Text(l.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(l.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => _openInWebView(l),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    switch (v) {
                      case 'open':
                        _openInWebView(l);
                        break;
                      case 'edit':
                        _editLink(l);
                        break;
                      case 'delete':
                        _confirmDelete(l);
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'open', child: ListTile(leading: Icon(Icons.open_in_new), title: Text('Open'))),
                    PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                    PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete'))),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: items.length,
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createLink,
        icon: const Icon(Icons.add),
        label: const Text('New Link'),
      ),
    );
  }

  Future<void> _showSearchSheet(BuildContext context) async {
    _searchCtrl.text = '';
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  labelText: 'Search links',
                  hintText: 'Title or URL',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => _controller.setSearch(v),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      _controller.setSearch('');
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _createLink() {
    Get.toNamed(
      Routes.editLink,
      arguments: {
        'appId': widget.appId,
        'link': null,
      },
    );
  }

  void _editLink(LinkModel link) {
    Get.toNamed(
      Routes.editLink,
      arguments: {
        'appId': widget.appId,
        'link': link,
      },
    );
  }

  Future<void> _confirmDelete(LinkModel link) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Link'),
        content: Text('Delete "${link.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await _controller.deleteLink(link.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${link.title}"')));
      }
    }
  }

  void _openInWebView(LinkModel link) {
    // Use lastUrl if present to "maintain current page", else original url.
    final urlToOpen = link.lastUrl?.isNotEmpty == true ? link.lastUrl! : link.url;

    Get.toNamed(
      Routes.browser,
      arguments: {'link': link.copyWith(lastUrl: urlToOpen)},
    );
  }
}

class _EmptyLinks extends StatelessWidget {
  final String? appName;
  const _EmptyLinks({this.appName});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link, size: 64, color: cs.primary),
            const SizedBox(height: 16),
            Text('No links yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Add your first link for ${appName ?? "this app"}. Configure JavaScript, zoom and local storage per link.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
