import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluffyx/l10n/l10n.dart';
import 'package:fluffyx/pages/new_private_chat/new_private_chat_view.dart';
import 'package:fluffyx/pages/new_private_chat/qr_scanner_modal.dart';
import 'package:fluffyx/utils/adaptive_bottom_sheet.dart';
import 'package:fluffyx/utils/fluffy_share.dart';
import 'package:fluffyx/utils/platform_infos.dart';
import 'package:fluffyx/utils/url_launcher.dart';
import 'package:fluffyx/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matrix/matrix.dart';

import '../../widgets/adaptive_dialogs/user_dialog.dart';

// FluffyX: search results with local contacts and server results separated
class UserSearchResults {
  final List<Profile> localContacts;
  final List<Profile> serverResults;

  const UserSearchResults({
    required this.localContacts,
    required this.serverResults,
  });

  bool get isEmpty => localContacts.isEmpty && serverResults.isEmpty;
}

class NewPrivateChat extends StatefulWidget {
  final String? deeplink;
  const NewPrivateChat({super.key, required this.deeplink});

  @override
  NewPrivateChatController createState() => NewPrivateChatController();
}

class NewPrivateChatController extends State<NewPrivateChat> {
  final TextEditingController controller = TextEditingController();
  final FocusNode textFieldFocus = FocusNode();

  // FluffyX: changed from Future<List<Profile>> to Future<UserSearchResults>
  Future<UserSearchResults>? searchResponse;

  Timer? _searchCoolDown;

  static const Duration _coolDown = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    final deeplink = widget.deeplink;
    if (deeplink != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UrlLauncher(context, deeplink).openMatrixToUrl();
      });
    }
  }

  // FluffyX: dispose controllers, focus node, and cancel search timer
  @override
  void dispose() {
    _searchCoolDown?.cancel();
    controller.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> searchUsers([String? input]) async {
    final searchTerm = input ?? controller.text;
    if (searchTerm.isEmpty) {
      _searchCoolDown?.cancel();
      setState(() {
        searchResponse = _searchCoolDown = null;
      });
      return;
    }

    _searchCoolDown?.cancel();
    _searchCoolDown = Timer(_coolDown, () {
      setState(() {
        searchResponse = _searchUser(searchTerm);
      });
    });
  }

  // FluffyX: local contacts search — filter direct chats by substring
  List<Profile> _getLocalContacts(String term) {
    final client = Matrix.of(context).client;
    final lowerTerm = term.toLowerCase();
    final localProfiles = <Profile>[];
    final seenIds = <String>{};

    for (final room in client.rooms) {
      if (!room.isDirectChat) continue;
      final directChatMatrixID = room.directChatMatrixID;
      if (directChatMatrixID == null) continue;
      if (seenIds.contains(directChatMatrixID)) continue;

      final displayName = room.getLocalizedDisplayname();
      if (displayName.toLowerCase().contains(lowerTerm) ||
          directChatMatrixID.toLowerCase().contains(lowerTerm)) {
        seenIds.add(directChatMatrixID);
        localProfiles.add(
          Profile(
            userId: directChatMatrixID,
            displayName: displayName,
            avatarUrl: room.avatar,
          ),
        );
      }
    }

    return localProfiles;
  }

  // FluffyX: combined local + server search with deduplication
  Future<UserSearchResults> _searchUser(String searchTerm) async {
    final localContacts = _getLocalContacts(searchTerm);
    final localIds = localContacts.map((p) => p.userId).toSet();

    final result = await Matrix.of(context).client.searchUserDirectory(
      searchTerm,
      limit: 20,
    );
    final serverProfiles =
        result.results.where((p) => !localIds.contains(p.userId)).toList();

    if (searchTerm.isValidMatrixId &&
        searchTerm.sigil == '@' &&
        !localIds.contains(searchTerm) &&
        !serverProfiles.any((profile) => profile.userId == searchTerm)) {
      serverProfiles.add(Profile(userId: searchTerm));
    }

    return UserSearchResults(
      localContacts: localContacts,
      serverResults: serverProfiles,
    );
  }

  void inviteAction() => FluffyShare.shareInviteLink(context);

  Future<void> openScannerAction() async {
    if (PlatformInfos.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt < 21) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context).unsupportedAndroidVersionLong),
          ),
        );
        return;
      }
    }
    await showAdaptiveBottomSheet(
      context: context,
      builder: (_) => QrScannerModal(
        onScan: (link) => UrlLauncher(context, link).openMatrixToUrl(),
      ),
    );
  }

  Future<void> copyUserId() async {
    await Clipboard.setData(
      ClipboardData(text: Matrix.of(context).client.userID!),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(L10n.of(context).copiedToClipboard)));
  }

  void openUserModal(Profile profile) =>
      UserDialog.show(context: context, profile: profile);

  @override
  Widget build(BuildContext context) => NewPrivateChatView(this);
}
