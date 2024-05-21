import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../utils/requests.dart';

class TeamChatPage extends StatefulWidget {
  late Timer _timer;
  @override
  _TeamChatPageState createState() => _TeamChatPageState();
}

class _TeamChatPageState extends State<TeamChatPage> {
  var bool = false;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messagesList = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getTeamChatData();
    widget._timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        _getTeamChatData();
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

  Future<void> _getTeamChatData() async {
    try {
      final response = await getTeamchatMessages();
      final data = json.decode(response);
      if (data.containsKey("teamchat")) {
        List<dynamic> receivedMessages = data["teamchat"];
        setState(() {
          messagesList =
              List<Map<String, dynamic>>.from(receivedMessages.reversed);
          WidgetsBinding.instance.addPostFrameCallback((_) {
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
          });
        });
      }
    } catch (e) {}
  }

  void _sendMessage() async {
    String messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      await sendTeamChatMessage(_messageController.text);
      _messageController.clear();
      await _getTeamChatData();
    }
  }

  @override
  Widget build(BuildContext context) {
    var datum = "";
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _getTeamChatData,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: messagesList.isEmpty
                      ? const Center(
                          child: Text(
                              'Noch keine Teamchat-Nachrichten vorhanden.'),
                        )
                      : Scrollbar(
                          controller: _scrollController,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: messagesList.length,
                            itemBuilder: (context, index) {
                              final message = messagesList[index];
                              var isSelfMessage = message['uid'] == selfUid;
                              var datumrow = "";
                              if (datum != message['datum']) {
                                datumrow = message['datum'];
                                datum = message['datum'];
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                    crossAxisAlignment: isSelfMessage
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 4.0, left: 4.0, right: 4.0),
                                        child: Text(
                                          message['nickname'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelfMessage
                                                ? Colors.green
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 4.0, left: 4.0, right: 4.0),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              maxWidth:
                                                  200.0), // Hier die maximale Breite setzen
                                          decoration: BoxDecoration(
                                            color: isSelfMessage
                                                ? Colors.green
                                                : Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            message['text'],
                                            style: TextStyle(
                                              color: isSelfMessage
                                                  ? Colors.white
                                                  : Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          '${message['uhrzeit']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
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
                                  hintText: 'Nachricht eingeben',
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
