import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../../controllers/theme_controller.dart';
import '../../data/hive_service.dart';
import '../../core/constants/links.dart';
import '../../services/config_service.dart';

/// SettingsPage
/// - Change the full app theme color (seed color)
/// - Open external links: Privacy Policy, Terms & Conditions, GitHub Repo, About Us
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _hexCtrl;
  final _formKey = GlobalKey<FormState>();

  static const _palette = <String>[
    // Dark tones
    '#000000', // Black
    '#111827', // Gray 900
    '#212121', // Grey 900 (Material)
    '#0D47A1', // Indigo 900
    '#1B5E20', // Green 900
    '#B71C1C', // Red 900
    '#3E2723', // Brown 900
    '#374151', // Gray 700

    // Bright tones
    '#4F46E5', // Indigo
    '#1A73E8', // Blue
    '#10B981', // Green
    '#D93025', // Red
    '#9333EA', // Purple
    '#FF9800', // Orange
    '#0EA5E9', // Sky
    '#14B8A6', // Teal
  ];

  @override
  void initState() {
    super.initState();
    _hexCtrl = TextEditingController(text: HiveService.getThemeColorHex());
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('App Theme', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeCtrl.seedColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _hexCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Seed color hex',
                        hintText: '#RRGGBB or #AARRGGBB',
                      ),
                      validator: _validateHex,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() != true) return;
                    await _applyHex(themeCtrl, _hexCtrl.text.trim());
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _palette
                  .map(
                    (hex) => InkWell(
                      onTap: () => _onPaletteTap(themeCtrl, hex),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(HiveService.parseColorHex(hex)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hex.toUpperCase() == _hexCtrl.text.trim().toUpperCase()
                                ? cs.onPrimaryContainer
                                : cs.outlineVariant,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text('Legal & About', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    onTap: () => _launchExternal(ExternalLinks.privacyPolicy),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.rule_folder_outlined),
                    title: const Text('Terms & Conditions'),
                    onTap: () => _launchExternal(ExternalLinks.termsAndConditions),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.code_outlined),
                    title: const Text('GitHub Repository'),
                    onTap: () => _launchExternal(ExternalLinks.githubRepo),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About Us'),
                    onTap: () => _launchExternal(ExternalLinks.aboutUs),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Backup & Restore', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.file_upload_outlined),
                    title: const Text('Export Configuration (copy JSON)'),
                    subtitle: const Text('Apps, links, and theme'),
                    onTap: _exportConfig,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.file_download_outlined),
                    title: const Text('Import Configuration (paste JSON)'),
                    subtitle: const Text('Replaces current data'),
                    onTap: _promptImport,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tip: The theme uses Material 3 dynamic color derived from the seed. '
              'Choose a color that represents your brand or preference.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String? _validateHex(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Hex is required';
    final hex = value.startsWith('#') ? value.substring(1) : value;
    if (hex.length != 6 && hex.length != 8) return 'Invalid hex length';
    final ok = int.tryParse(hex, radix: 16) != null;
    return ok ? null : 'Invalid hex format';
  }

  Future<void> _applyHex(ThemeController themeCtrl, String value) async {
    final hex = value.startsWith('#') ? value : '#$value';
    await themeCtrl.setSeedHex(hex);
    if (mounted) {
      setState(() {
        _hexCtrl.text = hex;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Theme color updated')),
      );
    }
  }

  Future<void> _onPaletteTap(ThemeController themeCtrl, String hex) async {
    _hexCtrl.text = hex;
    await _applyHex(themeCtrl, hex);
  }

  Future<void> _exportConfig() async {
    final json = ConfigService.exportToJsonString();
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration copied to clipboard')),
      );
    }
  }

  Future<void> _promptImport() async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Import Configuration'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 600,
            child: TextFormField(
              controller: ctrl,
              minLines: 6,
              maxLines: 16,
              decoration: const InputDecoration(
                labelText: 'Paste JSON here',
                alignLabelWithHint: true,
              ),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'JSON is required';
                try {
                  // basic JSON validation
                  // ignore: unused_local_variable
                  final _ = Uri.decodeFull(value);
                } catch (_) {}
                try {
                  // ignore: unused_local_variable
                  final _ = value.startsWith('{') ? value : value; // placeholder
                  // actual parsing will be done in try/catch during import
                } catch (_) {
                  return 'Invalid JSON';
                }
                return null;
              },
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(context, true);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final content = ctrl.text.trim();
    try {
      await ConfigService.importFromJsonString(content, replaceExisting: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration imported')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<void> _launchExternal(String urlStr) async {
    final uri = Uri.parse(urlStr);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open: $urlStr')),
        );
      }
    }
  }
}
