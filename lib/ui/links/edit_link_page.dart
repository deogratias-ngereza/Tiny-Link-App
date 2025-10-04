import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/link_controller.dart';
import '../../models/link_model.dart';
import '../../models/webview_config.dart';

/// EditLinkPage
/// - Create or edit a LinkModel under a specific App (appId).
/// - Fields: title, url, color hex, and per-link WebView configuration:
///   - JavaScript enabled
///   - Zoom enabled
///   - Local storage enabled
class EditLinkPage extends StatefulWidget {
  final String? appId;
  final LinkModel? link;

  const EditLinkPage({super.key, this.appId, this.link});

  @override
  State<EditLinkPage> createState() => _EditLinkPageState();
}

class _EditLinkPageState extends State<EditLinkPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _colorCtrl;
  bool _javascriptEnabled = true;
  bool _zoomEnabled = true;
  bool _localStorageEnabled = true;
  double _initialZoom = 1.0; // 1.0 = 100%
  bool _startFullscreen = false;
  String _homeIconPosition = 'topLeft';

  LinkController? _linkController; // Resolved via GetX using tag=appId

  @override
  void initState() {
    super.initState();
    final link = widget.link;
    _titleCtrl = TextEditingController(text: link?.title ?? '');
    _urlCtrl = TextEditingController(text: link?.url ?? '');
    _colorCtrl = TextEditingController(text: link?.colorHex ?? '#1A73E8');

    if (link != null) {
      _javascriptEnabled = link.config.javascriptEnabled;
      _zoomEnabled = link.config.zoomEnabled;
      _localStorageEnabled = link.config.localStorageEnabled;
      _initialZoom = link.config.initialZoom;
      _startFullscreen = link.config.startFullscreen;
      _homeIconPosition = link.config.homeIconPosition;
    }

    final appId = link?.appId ?? widget.appId;
    if (appId != null) {
      // The LinksPage registers LinkController with tag=appId
      _linkController = Get.find<LinkController>(tag: appId);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.link != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Link' : 'Create Link'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Inbox',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://example.com',
                ),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'URL is required';
                  final uri = Uri.tryParse(value);
                  if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
                    return 'Enter a valid http(s) URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _colorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Color hex',
                  hintText: '#RRGGBB or #AARRGGBB',
                ),
                validator: (v) {
                  final value = (v ?? '').trim();
                  final hex = value.startsWith('#') ? value.substring(1) : value;
                  if (hex.length != 6 && hex.length != 8) return 'Invalid hex length';
                  final ok = int.tryParse(hex, radix: 16) != null;
                  return ok ? null : 'Invalid hex format';
                },
              ),
              const SizedBox(height: 20),
              Text('WebView configuration', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _javascriptEnabled,
                onChanged: (v) => setState(() => _javascriptEnabled = v),
                title: const Text('Enable JavaScript'),
                subtitle: const Text('Allow the page to execute JavaScript'),
              ),
              SwitchListTile(
                value: _zoomEnabled,
                onChanged: (v) => setState(() => _zoomEnabled = v),
                title: const Text('Enable Zoom'),
                subtitle: const Text('Allow pinch-to-zoom and zoom controls'),
              ),
              SwitchListTile(
                value: _localStorageEnabled,
                onChanged: (v) => setState(() => _localStorageEnabled = v),
                title: const Text('Enable Local Storage'),
                subtitle: const Text('Allow webview to use local storage'),
              ),
              const SizedBox(height: 12),
              // Initial Zoom slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Initial zoom: ${(_initialZoom * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Slider(
                    value: _initialZoom,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15, // steps of ~0.1
                    label: '${(_initialZoom * 100).toStringAsFixed(0)}%',
                    onChanged: (v) => setState(() => _initialZoom = v),
                  ),
                ],
              ),
              // Fullscreen toggle
              SwitchListTile(
                value: _startFullscreen,
                onChanged: (v) => setState(() => _startFullscreen = v),
                title: const Text('Start in Fullscreen'),
                subtitle: const Text('Hide title and bottom controls; use Home to exit'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _homeIconPosition,
                decoration: const InputDecoration(
                  labelText: 'Fullscreen Home icon position',
                ),
                items: const [
                  DropdownMenuItem(value: 'topLeft', child: Text('Top Left')),
                  DropdownMenuItem(value: 'topCenter', child: Text('Top Center')),
                  DropdownMenuItem(value: 'topRight', child: Text('Top Right')),
                  DropdownMenuItem(value: 'centerLeft', child: Text('Center Left')),
                  DropdownMenuItem(value: 'center', child: Text('Center')),
                  DropdownMenuItem(value: 'centerRight', child: Text('Center Right')),
                  DropdownMenuItem(value: 'bottomLeft', child: Text('Bottom Left')),
                  DropdownMenuItem(value: 'bottomCenter', child: Text('Bottom Center')),
                  DropdownMenuItem(value: 'bottomRight', child: Text('Bottom Right')),
                ],
                onChanged: (v) => setState(() => _homeIconPosition = v ?? 'topLeft'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: Text(isEditing ? 'Save' : 'Create'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;

    final title = _titleCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    final colorHex = _colorCtrl.text.trim();
    final config = WebViewConfig(
      javascriptEnabled: _javascriptEnabled,
      zoomEnabled: _zoomEnabled,
      localStorageEnabled: _localStorageEnabled,
      initialZoom: _initialZoom,
      startFullscreen: _startFullscreen,
      homeIconPosition: _homeIconPosition,
    );

    if (widget.link == null) {
      // Creating requires appId and a LinkController
      final appId = widget.appId;
      if (appId == null || _linkController == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to create: missing app context')),
        );
        return;
      }
      await _linkController!.addLink(
        title: title,
        url: url,
        colorHex: colorHex,
        config: config,
      );
    } else {
      final original = widget.link!;
      final updated = original.copyWith(
        title: title,
        url: url,
        colorHex: colorHex,
        config: config,
        // keep lastUrl as-is; user can resume from where they left in browser
      );
      // Resolve controller using the link's appId (safer)
      final ctrl = _linkController ?? Get.find<LinkController>(tag: original.appId);
      await ctrl.updateLink(updated);
    }

    if (mounted) Navigator.pop(context);
  }
}
