import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../data/hive_service.dart';
import '../../routes/app_pages.dart';

/// AppsPage
/// - Home screen showing a list of "Apps" (groups) that contain multiple links.
/// - Users can add, rename, recolor, and delete apps.
/// - Tapping an app opens its links list.
class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  late final AppController _appController;

  @override
  void initState() {
    super.initState();
    _appController = Get.put(AppController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiny Link — Apps'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.settings),
          ),
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: Obx(() {
        final apps = _appController.apps;
        if (apps.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.apps, size: 64, color: cs.primary),
                  const SizedBox(height: 16),
                  Text(
                    'No apps yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an app (like "YouTube", "Gmail") to organize multiple links.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showCreateOrEditAppDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create your first app'),
                  )
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final a = apps[index];
            final color = Color(HiveService.parseColorHex(a.colorHex));
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
                  child: Icon(Icons.apps, color: color),
                ),
                title: Text(a.name, style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(a.colorHex, style: Theme.of(context).textTheme.bodySmall),
                onTap: () {
                  Get.toNamed(
                    Routes.links,
                    arguments: {'appId': a.id, 'appName': a.name},
                  );
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showCreateOrEditAppDialog(context, appId: a.id, initialName: a.name, initialColorHex: a.colorHex);
                        break;
                      case 'delete':
                        _confirmDeleteApp(context, a.id, a.name);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete'))),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: apps.length,
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOrEditAppDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New App'),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Tiny Link',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.link),
      children: const [
        Text('Organize app-specific links and open them in a configurable webview.'),
      ],
    );
  }

  Future<void> _showCreateOrEditAppDialog(
    BuildContext context, {
    String? appId,
    String? initialName,
    String? initialColorHex,
  }) async {
    final nameCtrl = TextEditingController(text: initialName ?? '');
    final colorCtrl = TextEditingController(text: initialColorHex ?? '#4F46E5');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appId == null ? 'Create App' : 'Edit App'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'App name', hintText: 'e.g., YouTube'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: colorCtrl,
                decoration: const InputDecoration(labelText: 'Color hex', hintText: '#RRGGBB or #AARRGGBB'),
                validator: (v) {
                  final value = (v ?? '').trim();
                  final hex = value.startsWith('#') ? value.substring(1) : value;
                  if (hex.length != 6 && hex.length != 8) return 'Invalid hex length';
                  final ok = int.tryParse(hex, radix: 16) != null;
                  return ok ? null : 'Invalid hex format';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              final name = nameCtrl.text.trim();
              final colorHex = colorCtrl.text.trim();
              if (appId == null) {
                await _appController.createApp(name: name, colorHex: colorHex);
              } else {
                final current = _appController.getById(appId);
                if (current != null) {
                  await _appController.updateApp(current.copyWith(name: name, colorHex: colorHex));
                }
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(appId == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteApp(BuildContext context, String appId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete App'),
        content: Text('Are you sure you want to delete "$name"? This does not remove its links data yet.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await _appController.deleteApp(appId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "$name"')));
      }
    }
  }
}
