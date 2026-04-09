import 'dart:ui';

abstract class AppConfig {
  // Const and final configuration values (immutable)
  static const Color primaryColor = Color(0xFF5625BA);
  static const Color primaryColorLight = Color(0xFFCCBDEA);
  static const Color secondaryColor = Color(0xFF41a2bc);

  static const Color chatColor = primaryColor;
  static const double messageFontSize = 16.0;
  static const bool allowOtherHomeservers = true;
  static const bool enableRegistration = true;
  static const bool hideTypingUsernames = false;

  static const String inviteLinkPrefix = 'https://matrix.to/#/';
  static const String deepLinkPrefix = 'ru.rwxxik.fluffyx://chat/';
  static const String schemePrefix = 'matrix:';
  static const String pushNotificationsChannelId = 'fluffyx_push';
  static const String pushNotificationsAppId = 'ru.rwxxik.fluffyx';
  static const double borderRadius = 16.0;
  static const double spaceBorderRadius = 11.0;
  static const double columnWidth = 360.0;

  static const String enablePushTutorial =
      'https://github.com/rwxxik/fluffyX/wiki/push';
  static const String encryptionTutorial =
      'https://github.com/rwxxik/fluffyX/wiki/encryption';
  static const String startChatTutorial =
      'https://github.com/rwxxik/fluffyX/wiki/start-chat';
  static const String howDoIGetStickersTutorial =
      'https://github.com/rwxxik/fluffyX/wiki/stickers';
  static const String appId = 'ru.rwxxik.fluffyx';
  static const String appOpenUrlScheme = 'ru.rwxxik.fluffyx';
  static const String appSsoUrlScheme = 'ru.rwxxik.fluffyx.auth';

  static const String sourceCodeUrl =
      'https://github.com/rwxxik/fluffyX';
  static const String supportUrl =
      'https://github.com/rwxxik/fluffyX/issues';
  static const String changelogUrl = 'https://github.com/rwxxik/fluffyX/releases';

  static const Set<String> defaultReactions = {'👍', '❤️', '😂', '😮', '😢'};

  static final Uri newIssueUrl = Uri(
    scheme: 'https',
    host: 'github.com',
    path: '/rwxxik/fluffyX/issues/new',
  );

  static final Uri homeserverList = Uri(
    scheme: 'https',
    host: 'raw.githubusercontent.com',
    path: 'rwxxik/fluffyX/refs/heads/main/recommended_homeservers.json',
  );

  static const String mainIsolatePortName = 'main_isolate';
  static const String pushIsolatePortName = 'push_isolate';
}
