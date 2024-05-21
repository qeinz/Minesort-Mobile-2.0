import 'package:flutter/material.dart';
import 'package:minesort/menu/sections/admin/user_actions/banns.dart';
import 'package:minesort/menu/sections/admin/user_actions/botcommands.dart';
import 'package:minesort/menu/sections/admin/user_actions/lastchannel.dart';
import 'package:minesort/menu/sections/admin/user_actions/coins.dart';
import 'package:minesort/menu/sections/admin/user_actions/connections.dart';
import 'dart:async';
import 'dart:convert';

import '../../../utils/requests.dart';

const backendURL = 'your_backend_url_here';

class UserDetailPage extends StatefulWidget {
  final String clientName;
  final String clientUid;

  const UserDetailPage({
    required this.clientName,
    required this.clientUid,
    super.key,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  Future<Map<String, dynamic>?>? userData;

  final TextEditingController _pokeMessageController = TextEditingController();
  final TextEditingController _kickReasonController = TextEditingController();

  int userTabSelected = 0;
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    userData = fetchUserData();
    _fetchIsMutedStatus().then((status) {
      setState(() {
        isMuted = status ==
            'true'; // Assuming the status is a string "true" or "false"
      });
    });
  }

  @override
  void dispose() {
    _pokeMessageController.dispose();
    _kickReasonController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      final response = await getClientInfos(widget.clientUid);
      final data = json.decode(response);

      if (data.containsKey('client')) {
        return {'client': data['client']};
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _refreshUserData() async {
    final updatedData = await fetchUserData();
    setState(() {
      userData = Future.value(updatedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientName),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: DefaultTabController(
          length: 3, // Anzahl der Tabs
          child: FutureBuilder<Map<String, dynamic>?>(
            future: userData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                final user = snapshot.data?['client'];
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    buildAvatar(user),
                    Container(
                      color: Colors.transparent,
                      child: TabBar(
                        labelColor: Colors.black,
                        tabs: [
                          Tab(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: userTabSelected == 0
                                  ? const Icon(Icons.info,
                                      key: Key('info_icon'), size: 28)
                                  : const Icon(Icons.info_outline,
                                      key: Key('info_outline_icon'), size: 28),
                            ),
                            child: const Text(
                              'Infos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Tab(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: userTabSelected == 1
                                  ? const Icon(Icons.settings,
                                      key: Key('settings_icon'), size: 28)
                                  : const Icon(Icons.settings_outlined,
                                      key: Key('settings_outline_icon'),
                                      size: 28),
                            ),
                            child: const Text(
                              'Actions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Tab(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: userTabSelected == 2
                                  ? const Icon(Icons.group,
                                      key: Key('group_icon'), size: 28)
                                  : const Icon(Icons.group_outlined,
                                      key: Key('group_outline_icon'), size: 28),
                            ),
                            child: const Text(
                              'Groups',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                        onTap: (index) {
                          setState(() {
                            userTabSelected = index;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Infos
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                buildUserDetails(user),
                              ],
                            ),
                          ),
                          // Tab 2: Actions
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                buildButtons(user),
                              ],
                            ),
                          ),
                          // Tab 3: Groups
                          const SingleChildScrollView(
                            child: Column(
                              children: [
                                // Inhalt für den "Groups"-Tab hier einführen
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: Text('Error loading user data'));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildAvatar(Map<String, dynamic> user) {
    final avatarUrl =
        'https://stats.minesort.de/avatars/${user['base64HashClientUID']}.png';
    return Container(
      width: 210,
      height: 210,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          width: 210,
          height: 210,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.account_circle,
              size: 160,
              color: Colors.white,
            );
          },
        ),
      ),
    );
  }

  Widget buildUserDetails(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildUserDetailItem(
                  'First Connection', user['firstConnection'] ?? 'N/A'),
              buildUserDetailItem('Registriert', user['registriert'] ?? 'N/A'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildUserDetailItem('IP', user['ip'] ?? 'N/A'),
              buildUserDetailItem('Land', user['land'] ?? 'N/A'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildUserDetailItem(
                  'Connections', user['connections']?.toString() ?? 'N/A'),
              buildUserDetailItem('Coins', user['coins']?.toString() ?? 'N/A'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildUserDetailItem('Version', user['version'] ?? 'N/A'),
              buildUserDetailItem(
                  'Idle Time',
                  user['idleTime'] != null
                      ? (user['idleTime'] / 60000).toStringAsFixed(2) + ' min.'
                      : 'N/A'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildUserDetailItem('Email', user['email'] ?? 'N/A'),
              buildUserDetailItem('Claimed', user['claimed'] ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  //TODO: namens history einbauen

  Widget buildUserDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<String> _fetchIsMutedStatus() async {
    final userDataMap = await userData;
    if (userDataMap != null) {
      final targetUid = userDataMap['client']['uid'];
      final response = await getClientMutedStatus(targetUid);
      return response;
    }
    return 'false'; // Default to false if no user data is available
  }

  Widget buildButtons(Map<String, dynamic> user) {
    final isTeamler = user['isTeamler'] == true;
    final hasConnections = user['hasConnections'] == true;
    final hasBans = user['hasBanns'] == true;
    final hasShopEntrys = user['hasShopEntrys'] == true;
    //final isRegistered = user['isRegistered'] == true;
    final hasBotCommands = user['hasBotCommands'] == true;
    final hasLastChannel = user['hasLastChannel'] == true;
    final hasCoinsLog = user['hasCoinsLog'] == true;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _openPokeDialog,
              icon: const Icon(Icons.touch_app, size: 24),
              label: const Text(
                'Poke',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: isTeamler ? null : _openKickDialog,
              icon: const Icon(Icons.exit_to_app, size: 24),
              label: const Text(
                'Kick',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: isTeamler
                  ? null
                  : () async {
                      await _muteClient();
                      setState(() {
                        isMuted = !isMuted;
                      });
                    },
              icon: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                size: 24,
              ),
              label: Text(
                isMuted ? 'Entmute' : 'Mute',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: isTeamler ? null : _openBanDialog,
              icon: const Icon(Icons.block, size: 24),
              label: const Text(
                'Ban',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: hasShopEntrys
                  ? () {
                      // Hier können Sie die Aktion für "Einkäufe" hinzufügen
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart, size: 24),
              label: const Text(
                'Einkäufe',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: hasCoinsLog
                  ? () async {
                      await _openCoinsDialog();
                    }
                  : null,
              icon: const Icon(Icons.monetization_on, size: 24),
              label: const Text(
                'Coinslog',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: hasConnections ? _openConnectionsDialog : null,
              icon: const Icon(Icons.account_tree_outlined, size: 24),
              label: const Text(
                'Connections',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: hasBans ? _openBansDialog : null,
              icon: const Icon(Icons.history, size: 24),
              label: const Text(
                'Ban-History',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: hasBotCommands ? _openBotCommandsDialog : null,
              icon: const Icon(Icons.textsms_outlined, size: 24),
              label: const Text(
                'Bot-Commands',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: hasLastChannel ? _openLastChannelsDialog : null,
              icon: const Icon(Icons.hourglass_bottom_sharp, size: 24),
              label: const Text(
                'Last-Channels',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: hasBotCommands
                  ? () {
                      _moveClient();
                    }
                  : null,
              icon: const Icon(Icons.account_tree_rounded, size: 24),
              label: const Text(
                'Move',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _moveClient() async {
    Map<String, dynamic>? userDataMap = await userData;
    moveClient(userDataMap?['client']['uid']);
  }

  Future<void> _openBotCommandsDialog() async {
    Map<String, dynamic>? userDataMap = await userData;

    if (userDataMap != null &&
        userDataMap['client'] != null &&
        userDataMap['client']['uid'] != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BotCommandsPage(
              clientName: userDataMap['client']['nickname'],
              uid: userDataMap['client']['uid']),
        ),
      );
    }
  }

  Future<void> _openLastChannelsDialog() async {
    Map<String, dynamic>? userDataMap = await userData;

    if (userDataMap != null &&
        userDataMap['client'] != null &&
        userDataMap['client']['uid'] != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LastChannelsPage(
              clientName: userDataMap['client']['nickname'],
              uid: userDataMap['client']['uid']),
        ),
      );
    }
  }

  Future<void> _muteClient() async {
    Map<String, dynamic>? userDataMap = await userData;

    if (userDataMap != null) {
      String targetUid = userDataMap['client']['uid'];

      String response = await muteClient(targetUid);

      if (response == 'Client gemuted') {
        showSuccessSnackbar('Client erfolgreich gemuted');
        setState(() {
          isMuted = false;
        });
      } else if (response == 'Client entmuted') {
        showSuccessSnackbar('Client erfolgreich entmuted');
        setState(() {
          isMuted = true;
        });
      } else {
        showErrorSnackbar('Es ist ein Fehler aufgetreten');
      }
    }
  }

  Future<void> _openPokeDialog() async {
    Map<String, dynamic>? userDataMap = await userData;

    if (userDataMap != null) {
      String targetUid = userDataMap['client']['uid'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Schreibe eine Nachricht.'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _pokeMessageController,
                  decoration: const InputDecoration(
                    labelText: 'Deine Nachricht...',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Abbrechen'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _pokeMessageController.clear();
                },
              ),
              ElevatedButton(
                child: const Text('Poken'),
                onPressed: () async {
                  String pokeMessage = _pokeMessageController.text;
                  String response =
                      await sendPokeMessage(pokeMessage, targetUid);

                  if (response == 'Client Poked') {
                    showSuccessSnackbar('Client erfolgreich gepoked');
                  } else {
                    showErrorSnackbar('Es ist ein Fehler aufgetreten');
                  }

                  Navigator.of(context).pop();
                  _pokeMessageController.clear();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _openKickDialog() async {
    Map<String, dynamic>? userDataMap = await userData;

    if (userDataMap != null) {
      String targetUid = userDataMap['client']['uid'];

      final response = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Grund für Kick eingeben'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _kickReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Grund für Kick...',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Abbrechen'),
                onPressed: () {
                  Navigator.of(context).pop(
                      'Abbrechen'); // Return a string to indicate cancellation
                },
              ),
              ElevatedButton(
                child: const Text('Kick'),
                onPressed: () async {
                  String kickReason = _kickReasonController.text;
                  String response = await kickClient(targetUid, kickReason);

                  if (response == 'Client wurde gekickt') {
                    showSuccessSnackbar('Client erfolgreich gekickt');
                    Navigator.of(context).pop(
                        'Erfolgreich'); // Return a string to indicate success
                  } else {
                    showErrorSnackbar('Es ist ein Fehler aufgetreten');
                  }
                  _kickReasonController.clear();
                },
              ),
            ],
          );
        },
      );

      if (response == 'Erfolgreich') {
        // Navigate back to the admin page
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _openBanDialog() async {
    Map<String, dynamic>? userDataMap = await userData;

    if (userDataMap != null) {
      final TextEditingController banReasonController = TextEditingController();
      DateTime? selectedDate;

      final response = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Grund für Bann eingeben'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: banReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Grund für Bann...',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Ablaufdatum und Uhrzeit auswählen'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? selected = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (selected != null) {
                      final TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        final DateTime selectedDateTime = DateTime(
                          selected.year,
                          selected.month,
                          selected.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        selectedDate = selectedDateTime;
                      }
                    }
                  },
                ),
                if (selectedDate != null)
                  Text(
                      'Ausgewählte Datum und Uhrzeit: ${selectedDate?.toLocal()}'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Abbrechen'),
                onPressed: () {
                  Navigator.of(context).pop('Abbrechen');
                },
              ),
              ElevatedButton(
                child: const Text('Bannen'),
                onPressed: () async {
                  String banReason = banReasonController.text;
                  if (banReason.isNotEmpty && selectedDate != null) {
                    final durationInSeconds =
                        selectedDate!.difference(DateTime.now()).inSeconds;

                    String response = await banClient(
                      userDataMap['client']['uid'],
                      banReason,
                      durationInSeconds.toString(),
                    );

                    if (response == 'Client wurde gebannt') {
                      showSuccessSnackbar('Client erfolgreich gebannt');
                      Navigator.of(context).pop('Erfolgreich');
                    } else {
                      showErrorSnackbar('Es ist ein Fehler aufgetreten');
                      Navigator.of(context).pop();
                    }
                    banReasonController.clear();
                  }
                },
              ),
            ],
          );
        },
      );

      if (response == 'Erfolgreich') {
        // Navigation zur Admin-Seite nach erfolgreichem Bann
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _openConnectionsDialog() async {
    Map<String, dynamic>? userDataMap = await userData;

    if (userDataMap != null &&
        userDataMap['client'] != null &&
        userDataMap['client']['uid'] != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ConnectionsPage(
              clientName: userDataMap['client']['nickname'],
              uid: userDataMap['client']['uid']),
        ),
      );
    }
  }

  Future<void> _openCoinsDialog() async {
    Map<String, dynamic>? userDataMap = await userData;

    if (userDataMap != null &&
        userDataMap['client'] != null &&
        userDataMap['client']['uid'] != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CoinsPage(
              clientName: userDataMap['client']['nickname'],
              coins: userDataMap['client']['coins'],
              uid: userDataMap['client']['uid']),
        ),
      );
    }
  }

  Future<void> _openBansDialog() async {
    Map<String, dynamic>? userDataMap = await userData;

    if (userDataMap != null &&
        userDataMap['client'] != null &&
        userDataMap['client']['uid'] != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BansPage(
              clientName: userDataMap['client']['nickname'],
              uid: userDataMap['client']['uid']),
        ),
      );
    }
  }

  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(message, textAlign: TextAlign.center),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(message, textAlign: TextAlign.center),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
