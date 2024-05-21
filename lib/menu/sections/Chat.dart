import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minesort/utils/requests.dart';

import 'chat/privatchat.dart';
import 'chat/teamchat.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late Future<String> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = getContactsFromClient();
  }

  Future<void> _refreshContactsData() async {
    final updatedData = await getContactsFromClient();
    setState(() {
      _contactsFuture = Future.value(updatedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    var tab = const TabBar(tabs: []);
    if (apikey != "ERROR") {
      tab = const TabBar(tabs: [
        Tab(text: 'Privat Chat'),
        Tab(text: 'Team Chat'),
      ]);
    } else {
      tab = const TabBar(tabs: [
        Tab(text: 'Privat Chat'),
      ]);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: AppBar(
                centerTitle: true,
                bottom: tab,
              ),
            ),
            body: SafeArea(
              child: TabBarView(
                children: [
                  Scaffold(
                    body: RefreshIndicator(
                      onRefresh: _refreshContactsData,
                      child: FutureBuilder<String>(
                        future: _contactsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Fehler beim Laden der Kontakte: ${snapshot.error}',
                              ),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: Text('Konnte keine Kontakte laden.'),
                            );
                          }

                          final contactsData =
                              json.decode(snapshot.data ?? '{}');
                          final contactsList = contactsData['contacts'];

                          if (contactsList.isEmpty) {
                            return const Center(
                              child: Text('Keine Kontakte vorhanden.'),
                            );
                          }

                          return ListView(
                            children: [
                              for (var contact in contactsList)
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      'https://stats.minesort.de/avatars/${contact['hasheduid']}.png',
                                    ),
                                  ),
                                  title: Text(
                                    contact['name'],
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  onTap: () async {
                                    // Navigiere zur privaten Chat-Ansicht
                                    final result =
                                        await Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => PrivateChatPage(
                                          clientName: contact['name'],
                                          clientPairId: contact['pairid'],
                                          clientUid: contact['uid'],
                                          context: context,
                                          hasheduid: contact['hasheduid'],
                                        ),
                                      ),
                                    );
                                    // Überprüfen, ob ein Client gelöscht wurde
                                    if (result == true) {
                                      // Ein Client wurde gelöscht, daher rufen Sie _refreshContactsData auf
                                      await _refreshContactsData();
                                    }
                                  },
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.endDocked,
                    floatingActionButton: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: FloatingActionButton(
                        onPressed: () {
                          _showUserSelectionDialog(context);
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ),
                  // Tab "Teamchat" Inhalt
                  if (apikey != "ERROR") TeamChatPage(),
                ],
              ),
            )),
      ),
    );
  }

  Future<List<String>> getExistingContactUIDs() async {
    try {
      final response = await getContactsFromClient();
      final contactsData = json.decode(response);
      final contactsList = contactsData['contacts'];

      if (contactsList is List) {
        final existingUIDs = contactsList.map((contact) {
          return contact['uid'].toString();
        }).toList();
        return existingUIDs;
      } else {
        return [];
      }
    } catch (e) {
      return [];
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

  Future<void> addChatContact(String targetUid) async {
    final response = await addChatContactByClient(targetUid);

    if (response == "done") {
      showSuccessSnackbar('Kontakt erfolgreich hinzugefügt.');
      await _refreshContactsData();
    } else {
      showErrorSnackbar('Fehler beim Hinzufügen des Kontakts.');
    }
  }

  Future<void> _showUserSelectionDialog(BuildContext context) async {
    final String jsonResponse = await getAllPossibleContacts();
    final List<dynamic> data = json.decode(jsonResponse)['allcontacts'];
    final List<String> usernames =
        data.map((item) => item['name'].toString()).toList();

    final List<String> existingContactUIDs = await getExistingContactUIDs();

    final List<String> filteredUsernames = usernames.where((username) {
      final userData =
          data.firstWhere((item) => item['name'].toString() == username);
      final userUID = userData['uid'].toString();
      return !existingContactUIDs.contains(userUID);
    }).toList();

    if (!android) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          String selectedUser =
              filteredUsernames.isNotEmpty ? filteredUsernames[0] : '';

          if (filteredUsernames.isEmpty) {
            return CupertinoAlertDialog(
              title: const Text('Keine neuen Benutzer verfügbar'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          }

          return CupertinoAlertDialog(
            title: const Text('Wähle einen Nutzer'),
            content: SizedBox(
              height: 120,
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (int index) {
                  selectedUser = filteredUsernames[index];
                },
                children: [
                  for (String username in filteredUsernames)
                    Center(
                      child: Text(username),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () async {
                  final selectedUserData = data.firstWhere(
                      (item) => item['name'].toString() == selectedUser);
                  final selectedUserUid = selectedUserData['uid'].toString();
                  addChatContact(selectedUserUid);
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          String selectedUser =
              filteredUsernames.isNotEmpty ? filteredUsernames[0] : '';
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Wähle einen Nutzer'),
                content: SizedBox(
                  height: 120,
                  child: SingleChildScrollView(
                    child: Column(
                      children: filteredUsernames.map((username) {
                        return RadioListTile<String>(
                          title: Text(username),
                          value: username,
                          groupValue: selectedUser,
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                selectedUser = value;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (selectedUser != null) {
                        final selectedUserData = data.firstWhere(
                            (item) => item['name'].toString() == selectedUser);
                        final selectedUserUid =
                            selectedUserData['uid'].toString();
                        addChatContact(selectedUserUid);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }
}

class ChatViewWidget extends StatelessWidget {
  final String pairId;

  const ChatViewWidget({
    required this.pairId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final backgroundColor =
        brightness == Brightness.dark ? Colors.black : Colors.white;

    return SizedBox(
      height: 600,
      child: FutureBuilder<String>(
        future: getChatByClientData(pairId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messagesData = json.decode(snapshot.data ?? '{}');
            final messagesList = messagesData['messages'];
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chat Name',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                for (var message in messagesList)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 5),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                            color: backgroundColor,
                          ),
                          child: Text(
                            message['text'],
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 17, left: 3),
                          child: Text(
                            message['uhrzeit'],
                            style: const TextStyle(fontSize: 11),
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
