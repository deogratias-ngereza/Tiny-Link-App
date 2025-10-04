import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../controllers/link_controller.dart';
import '../../data/hive_service.dart';
import '../../models/link_model.dart';
import '../../routes/app_pages.dart';
import '../../controllers/tabs_controller.dart';

/// BrowserPage (webview_flutter)
/// - Opens a given [LinkModel] in a WebView.
/// - Applies per-link config: JavaScript enabled/disabled.
/// - Approximates local storage disabling by injecting JS shim (see notes).
/// - Maintains current page (updates link.lastUrl on URL change).
/// - Provides back/forward/reload controls.
/// - Disables system back pop; uses webview back instead.
/// - Fullscreen mode: hides bars and shows configurable Home FAB position.
class BrowserPage extends StatefulWidget {
  final LinkModel link;

  const BrowserPage({super.key, required this.link});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  late final WebViewController _controller;
  late String _currentUrl;

  bool _loading = true;
  bool _canBack = false;
  bool _canForward = false;

  Color _onLinkColor(Color c) => c.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.link.lastUrl?.isNotEmpty == true ? widget.link.lastUrl! : widget.link.url;
    Get.put(TabsController(), permanent: true).addOrActivate(widget.link);

    _controller = WebViewController()
      ..setBackgroundColor(Colors.transparent)
      ..setJavaScriptMode(
        widget.link.config.javascriptEnabled ? JavaScriptMode.unrestricted : JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            _updateUrl(request.url);
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            _setLoading(true);
            _updateUrl(url);
          },
          onUrlChange: (change) {
            if (change.url != null) {
              _updateUrl(change.url!);
            }
          },
          onPageFinished: (url) async {
            // Apply local storage "disable" shim if requested.
            if (!widget.link.config.localStorageEnabled && widget.link.config.javascriptEnabled) {
              await _controller.runJavaScriptReturningResult(_localStorageDisableShim);
            }
            // Apply initial zoom (best-effort via JS/CSS/meta viewport).
            await _applyInitialZoom();
            _setLoading(false);
            _refreshNavAvailability();
          },
          onWebResourceError: (error) {
            _setLoading(false);
            _refreshNavAvailability();
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  Future<void> _refreshNavAvailability() async {
    final back = await _controller.canGoBack();
    final forward = await _controller.canGoForward();
    if (mounted) {
      setState(() {
        _canBack = back;
        _canForward = forward;
      });
    }
  }

  void _setLoading(bool value) {
    if (mounted) {
      setState(() => _loading = value);
    }
  }

  void _updateUrl(String url) async {
    _currentUrl = url;
    try {
      final ctrl = Get.find<LinkController>(tag: widget.link.appId);
      await ctrl.updateLastUrl(widget.link.id, url);
    } catch (_) {
      // Controller might not be present if page was launched outside expected flow.
    }
    _refreshNavAvailability();
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      _refreshNavAvailability();
    }
  }

  Future<void> _goForward() async {
    if (await _controller.canGoForward()) {
      await _controller.goForward();
      _refreshNavAvailability();
    }
  }

  Future<void> _reload() async {
    await _controller.reload();
    _refreshNavAvailability();
  }

  @override
  Widget build(BuildContext context) {
    final link = widget.link;
    final color = Color(HiveService.parseColorHex(link.colorHex));
    final onColor = _onLinkColor(color);
    final isLight = color.computeLuminance() > 0.5;
    final overlayBrightness = isLight ? Brightness.dark : Brightness.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: overlayBrightness,
        systemNavigationBarColor: color,
        systemNavigationBarIconBrightness: overlayBrightness,
      ),
      child: WillPopScope(
        onWillPop: _handleWillPop,
        child: Scaffold(
          appBar: link.config.startFullscreen
              ? null
              : AppBar(
                  backgroundColor: color,
                  foregroundColor: onColor,
                  leading: IconButton(
                    tooltip: 'Actions',
                    icon: const Icon(Icons.home),
                    onPressed: () => _showActionsMenu(context, color, onColor),
                  ),
                  title: Text(link.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  actions: [
                    if (_loading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: onColor),
                        ),
                      ),
                    IconButton(
                      tooltip: 'Actions',
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showActionsMenu(context, color, onColor),
                    ),
                    IconButton(
                      tooltip: 'Reload',
                      icon: const Icon(Icons.refresh),
                      onPressed: _reload,
                    ),
                  ],
                ),
          body: SafeArea(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: onColor,
                      backgroundColor: color.withOpacity(0.3),
                    ),
                  ),
                if (link.config.startFullscreen) _positionedHomeButton(color, onColor),
              ],
            ),
          ),
          bottomNavigationBar: link.config.startFullscreen
              ? null
              : SafeArea(
                  child: Container(
                    color: color,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _canBack ? _goBack : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: onColor,
                            side: BorderSide(color: onColor),
                          ),
                          icon: Icon(Icons.arrow_back, color: onColor),
                          label: Text('Back', style: TextStyle(color: onColor)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              _currentUrl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onColor),
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _canForward ? _goForward : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: onColor,
                            side: BorderSide(color: onColor),
                          ),
                          icon: Icon(Icons.arrow_forward, color: onColor),
                          label: Text('Forward', style: TextStyle(color: onColor)),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<bool> _handleWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      _refreshNavAvailability();
      return false; // don't pop page
    }
    return false; // block system back; use Home to exit
  }

  Widget _positionedHomeButton(Color color, Color onColor) {
    final pos = widget.link.config.homeIconPosition;
    final btn = FloatingActionButton.small(
      heroTag: 'home_fab',
      backgroundColor: color,
      foregroundColor: onColor,
      onPressed: () => _showActionsMenu(context, color, onColor),
      child: const Icon(Icons.home),
    );
    switch (pos) {
      case 'topCenter':
        return Align(alignment: Alignment.topCenter, child: Padding(padding: const EdgeInsets.only(top: 12), child: btn));
      case 'topRight':
        return Positioned(top: 12, right: 12, child: btn);
      case 'centerLeft':
        return Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 12), child: btn));
      case 'center':
        return Align(alignment: Alignment.center, child: btn);
      case 'centerRight':
        return Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(right: 12), child: btn));
      case 'bottomLeft':
        return Positioned(bottom: 24, left: 12, child: btn);
      case 'bottomCenter':
        return Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 24), child: btn));
      case 'bottomRight':
        return Positioned(bottom: 24, right: 12, child: btn);
      case 'topLeft':
      default:
        return Positioned(top: 12, left: 12, child: btn);
    }
  }

  Future<void> _showActionsMenu(BuildContext context, Color color, Color onColor) async {
    final tabsCtrl = Get.put(TabsController(), permanent: true);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Go Home (Apps)'),
                onTap: () {
                  Navigator.pop(context);
                  Get.offAllNamed(Routes.apps);
                },
              ),
              ListTile(
                leading: const Icon(Icons.explore),
                title: const Text('Go to Start URL'),
                onTap: () {
                  Navigator.pop(context);
                  _controller.loadRequest(Uri.parse(widget.link.url));
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Reload'),
                onTap: () {
                  Navigator.pop(context);
                  _reload();
                },
              ),
              ListTile(
                leading: const Icon(Icons.tab),
                title: Text('Tabs (${tabsCtrl.count})'),
                onTap: () {
                  Navigator.pop(context);
                  _showTabsSheet(context, color, onColor);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showTabsSheet(BuildContext context, Color color, Color onColor) async {
    final tabsCtrl = Get.find<TabsController>();
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) {
        final tabs = tabsCtrl.tabs;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tabs.isEmpty)
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('No open tabs'),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: tabs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = tabs[index];
                      return ListTile(
                        leading: const Icon(Icons.link),
                        title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(t.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          Navigator.pop(context);
                          Get.toNamed(Routes.browser, arguments: {'link': t});
                        },
                        trailing: IconButton(
                          tooltip: 'Close',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            tabsCtrl.closeTabById(t.id);
                            (context as Element).markNeedsBuild();
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      tabsCtrl.closeAll();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Close all'),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _applyInitialZoom() async {
    final z = widget.link.config.initialZoom;
    if (z == 1.0) return;
    final js = """
(() => {
  try {
    var z = $z;
    var meta = document.querySelector('meta[name=viewport]');
    if (!meta) {
      meta = document.createElement('meta');
      meta.name = 'viewport';
      document.head.appendChild(meta);
    }
    meta.setAttribute('content', 'width=device-width, initial-scale=' + z + ', maximum-scale=5.0, minimum-scale=0.1, user-scalable=yes');
    document.documentElement.style.zoom = z;
    if (document.body) { document.body.style.zoom = z; }
    return true;
  } catch (e) { return false; }
})();
""";
    try {
      await _controller.runJavaScriptReturningResult(js);
    } catch (_) {
      // Ignore if page CSP blocks inline JS transforms
    }
  }

  // JS snippet that overrides localStorage APIs to no-op when disabled.
  static const String _localStorageDisableShim = r"""
(() => {
  try {
    const noop = () => {};
    const fakeStore = {
      getItem: (_k) => null,
      setItem: (_k, _v) => {},
      removeItem: (_k) => {},
      clear: () => {},
      key: (_i) => null,
      get length() { return 0; }
    };
    Object.defineProperty(window, 'localStorage', { value: fakeStore, configurable: false });
    return true;
  } catch (e) {
    return false;
  }
})();
""";
}
