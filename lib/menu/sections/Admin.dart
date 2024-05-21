import 'package:flutter/material.dart';
import 'package:minesort/menu/sections/admin/Badword.dart';
import 'package:minesort/menu/sections/admin/user.dart';
import 'dart:async';
import 'dart:convert';

import '../../utils/requests.dart';
import 'admin/OfflineUser.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  Future<Map<String, List<User>?>?>? channelData;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    channelData = getChannelData();
  }

  Future<Map<String, List<User>?>?> getChannelData() async {
    try {
      final response = await getTs3UsersFromFlutter();
      final data = json.decode(response);

      if (data is Map<String, dynamic>) {
        final sortedChannelData = Map.fromEntries(data.entries.toList()
          ..sort((a, b) => int.parse(a.value['channelID'].toString())
              .compareTo(int.parse(b.value['channelID'].toString()))));

        Map<String, List<User>> channelData = {};
        sortedChannelData.forEach((channelName, channelInfo) {
          if (channelInfo is Map<String, dynamic>) {
            final clients = channelInfo['clients'] as List;
            List<User> users =
                clients.map((userData) => User.fromJson(userData)).toList();

            users
                .sort((a, b) => b.clientTalkpower.compareTo(a.clientTalkpower));
            channelData[channelName] = users;
          }
        });
        return channelData;
      } else {
        throw Exception("Ungültiges Datenformat");
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _refreshContactsData() async {
    final updatedChannelData = await getChannelData();

    setState(() {
      channelData = Future.value(updatedChannelData);
    });
  }

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            centerTitle: true,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'User'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _refreshContactsData,
              child: FutureBuilder<Map<String, List<User>?>?>(
                future: channelData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    final channelData = snapshot.data!;
                    return buildChannelData(channelData);
                  } else {
                    return const Text("Error");
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Badword(),
                        ),
                      );
                    },
                    child: const Text("Badwords"),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const OfflineUser(),
                        ),
                      );
                    },
                    child: const Text("Offline user"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
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

  Widget buildChannelData(Map<String, List<User>?>? channelData) {
    if (channelData == null) {
      return const Text("No data");
    }

    return Scrollbar(
      controller: _scrollController,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final channelName = channelData.keys.elementAt(index);
              final clientList = channelData[channelName]!;
              return ExpansionTile(
                title: Text('$channelName - (${clientList.length})'),
                children: clientList.map((user) {
                  return ListTile(
                    title: replaceEmojisWithIcons(user.clientName),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserDetailPage(
                            clientName: extractNickName(user.clientName),
                            clientUid: user.clientUid,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            }, childCount: channelData.length),
          ),
        ],
      ),
    );
  }

  String extractNickName(String text) {
    List<String> nickNameList = [];

    for (int rune in text.runes) {
      final runeString = String.fromCharCode(rune);

      switch (runeString) {
        case '⭕':
        case '🔵':
        case '💤':
        case '🎙':
        case '🔇':
        case '👑':
          break;
        default:
          nickNameList.add(runeString);
          break;
      }
    }
    return nickNameList.join('');
  }

  Widget replaceEmojisWithIcons(String text) {
    List<Widget> widgets = [];
    List<String> emojiList = [];

    for (int rune in text.runes) {
      final runeString = String.fromCharCode(rune);
      String imagePath;

      switch (runeString) {
        case '⭕':
          imagePath = 'assets/client_normal-5.png';
          break;
        case '🔵':
          imagePath = 'assets/client_talking-5.png';
          break;
        case '💤':
          imagePath = 'assets/client_away.png';
          break;
        case '🎙':
          imagePath = 'assets/input_muted-5.png';
          break;
        case '🔇':
          imagePath = 'assets/output_muted-5.png';
          break;
        case '👑': // Lasse die Krone stehen
          widgets.add(
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                runeString,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
          continue; // Springe zum nächsten Schleifen-Durchlauf, um das Hinzufügen eines Icons zu vermeiden
        default:
          imagePath =
              ''; // Setze hier den Standardpfad oder lasse es leer, je nach Bedarf.
          break;
      }

      if (imagePath.isNotEmpty) {
        // Füge Icon hinzu
        widgets.add(
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset(
              imagePath,
              height: 18,
              width: 18,
            ),
          ),
        );
      } else {
        emojiList.add(runeString);
      }
    }

    // Füge den restlichen Text hinzu
    widgets.add(
      Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          emojiList.join(''),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );

    return Row(
      children: widgets,
    );
  }
}

class User {
  final String clientName;
  final String clientUid;
  final int clientTalkpower;

  User({
    required this.clientName,
    required this.clientUid,
    required this.clientTalkpower,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      clientName: json['clientName'],
      clientUid: json['clientUid'],
      clientTalkpower: json['clientTalkpower'],
    );
  }
}
