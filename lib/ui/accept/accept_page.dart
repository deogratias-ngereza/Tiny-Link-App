import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/hive_service.dart';
import '../../routes/app_pages.dart';

/// AcceptPage
/// - Simple first-run screen to accept terms before using the app.
/// - Persists acceptance in local database (Hive) and then routes to Apps list.
class AcceptPage extends StatefulWidget {
  const AcceptPage({super.key});

  @override
  State<AcceptPage> createState() => _AcceptPageState();
}

class _AcceptPageState extends State<AcceptPage> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Tiny Link'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.link, size: 56, color: cs.primary),
              const SizedBox(height: 16),
              Text(
                'Accept & Continue',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Before you continue, please accept our basic terms. '
                'You can manage app-specific links, open them in a webview, and configure per-link webview settings.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v ?? false),
                title: const Text('I accept the terms to use Tiny Link'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _accepted ? _onAccept : null,
                      child: const Text('Accept and Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onAccept() async {
    await HiveService.setAccepted(true);
    if (mounted) {
      Get.offAllNamed(Routes.apps);
    }
  }
}
