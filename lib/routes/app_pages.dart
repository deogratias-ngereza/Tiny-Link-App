import 'package:get/get.dart';

import '../ui/apps/apps_page.dart';
import '../ui/links/links_page.dart';
import '../ui/links/edit_link_page.dart';
import '../ui/browser/browser_page.dart';
import '../ui/accept/accept_page.dart';
import '../ui/settings/settings_page.dart';

/// Route name constants used across the app.
class Routes {
  static const String apps = '/';
  static const String links = '/links';
  static const String editLink = '/edit-link';
  static const String browser = '/browser';
  static const String accept = '/accept';
  static const String settings = '/settings';
}

/// Centralized GetX page registry.
class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: Routes.accept,
      page: () => const AcceptPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.apps,
      page: () => const AppsPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.links,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final appId = args?['appId'] as String?;
        final appName = args?['appName'] as String?; // for display convenience
        if (appId == null) {
          throw ArgumentError('Routes.links requires argument: { "appId": String }');
        }
        return LinksPage(appId: appId, appName: appName);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.editLink,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return EditLinkPage(
          appId: args?['appId'] as String?,
          link: args?['link'],
        );
      },
      fullscreenDialog: true,
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.browser,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final link = args?['link'];
        if (link == null) {
          throw ArgumentError('Routes.browser requires argument: { "link": LinkModel }');
        }
        return BrowserPage(link: link);
      },
      transition: Transition.cupertino,
    ),
  ];
}
