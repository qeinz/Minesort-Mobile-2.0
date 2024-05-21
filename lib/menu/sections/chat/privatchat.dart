import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../utils/requests.dart';

class PrivateChatPage extends StatelessWidget {
  final String clientName;
  final String clientPairId;
  final String clientUid;
  final String hasheduid;
  final BuildContext context;

  const PrivateChatPage({
    required this.clientName,
    required this.clientPairId,
    required this.clientUid,
    required this.context,
    required this.hasheduid,
    super.key,
  });

  Future<void> deleteClient() async {
    final response = await removeChatContactByClient(clientUid);

    if (response == "done") {
      showSuccessSnackbar('Kontakt erfolgreich entfernt.');
    } else {
      showErrorSnackbar('Fehler beim Entfernen des Kontakts.');
    }
  }

  Future<void> emptyClient() async {
    final response = await emptyChatContactByClient(clientPairId, clientUid);

    if (response == "done") {
      showSuccessSnackbar('Chat erfolgreich geleert.');
    } else {
      showErrorSnackbar('Fehler beim leeren des Chats.');
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Kontakt entfernen'),
          content: const Text('Möchten Sie den Kontakt wirklich entfernen?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dialog schließen
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dialog schließen
                Navigator.of(context)
                    .pop(true); // Zurück zur vorherigen Ansicht
                deleteClient();
              },
              child: const Text('Entfernen'),
            ),
          ],
        );
      },
    );
  }

  void _showEmptyConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Chat leeren'),
          content: const Text('Möchten Sie den Chat wirklich leeren?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dialog schließen
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dialog schließen
                emptyClient();
              },
              child: const Text('Leeren'),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => User(
                      name: clientName, uid: clientUid, hasheduid: hasheduid),
                ),
              );
            },
            child: Text(clientName),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded),
              onPressed: () {
                _showEmptyConfirmationDialog();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog();
              },
            ),
          ],
        ),
        body: PrivateChatView(pairId: clientPairId, uid: clientUid),
      ),
    );
  }
}

class User extends StatelessWidget {
  final String name;
  final String uid;
  final String hasheduid;

  const User({
    super.key,
    required this.name,
    required this.uid,
    required this.hasheduid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: ClipOval(
        child: Image.network(
          'https://stats.minesort.de/avatars/$hasheduid.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return ClipOval(
              child: Image.asset(
                'assets/images/profile.png',
                height: 400,
                width: 400,
              ),
            );
          },
        ),
      ),
    );
  }
}

class PrivateChatView extends StatefulWidget {
  final String pairId;
  final String uid;
  late Timer _timer;

  PrivateChatView({
    required this.pairId,
    required this.uid,
    super.key,
  });

  @override
  _PrivateChatViewState createState() => _PrivateChatViewState();
}

class _PrivateChatViewState extends State<PrivateChatView> {
  List<Map<String, dynamic>> messagesList = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  int previousMessageCount = 0;
  var bool = false;

  @override
  void initState() {
    super.initState();
    _getChatData();

    widget._timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        _refreshChatData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (widget._timer.isActive) {
      widget._timer.cancel();
    }
  }

  Future<void> _getChatData() async {
    try {
      final response = await getChatByClientData(widget.pairId);
      final data = json.decode(response);
      if (data.containsKey("messages")) {
        List<dynamic> receivedMessages = data["messages"];
        if (mounted) {
          setState(() {
            messagesList =
                List<Map<String, dynamic>>.from(receivedMessages.reversed);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if(messagesList.isNotEmpty) {
                if (!bool) {
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
                  bool = true;
                }
                if (_scrollController.position.pixels ==
                    _scrollController.position.maxScrollExtent) {
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
                }
              }
            });
          });
        }
        if (messagesList.length > previousMessageCount) {
          previousMessageCount = messagesList.length;
          _scrollController.jumpTo(0.0);
        }
      }
    } catch (e) {}
  }

  Future<void> _refreshChatData() async {
    await _getChatData();
  }

  void _sendMessage() async {
    String messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      postPrivatChatByClient(widget.pairId, messageText, widget.uid);
      _messageController.clear();
      await _refreshChatData();
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      await _refreshChatData();
    }
  }

  @override
  Widget build(BuildContext context) {
    var datum = "";
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: _refreshChatData,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: messagesList.isEmpty
                      ? const Center(
                          child: Text('Beginne eine Konversation ...'),
                        )
                      : Scrollbar(
                          controller: _scrollController,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: messagesList.length,
                            itemBuilder: (context, index) {
                              final message = messagesList[index];
                              final isSent = message['sent'] == true;

                              var datumrow = "";
                              if (datum != message['datum']) {
                                datumrow = message['datum'];
                                datum = message['datum'];
                              }

                              return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Column(children: [
                                      Text(
                                        datumrow,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ]),
                                    Column(
                                      crossAxisAlignment: isSent
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                                maxWidth: 200.0),
                                            // Hier die maximale Breite setzen
                                            decoration: BoxDecoration(
                                              color: isSent
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              message['text'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8.0, 0.0, 8.0, 8.0),
                                          child: Text(
                                            '${message['uhrzeit']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                            textAlign: isSent
                                                ? TextAlign.right
                                                : TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    )
                                  ]);
                            },
                          ),
                        ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: Colors.black),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Nachricht eingeben ...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
