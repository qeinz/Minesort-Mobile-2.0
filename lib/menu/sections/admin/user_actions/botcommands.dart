import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../utils/requests.dart';

class BotCommandsPage extends StatefulWidget {
  final String clientName;
  final String uid;

  const BotCommandsPage({
    required this.clientName,
    required this.uid,
    super.key,
  });

  @override
  _BotCommandsPageState createState() => _BotCommandsPageState();
}

class _BotCommandsPageState extends State<BotCommandsPage> {
  List<Map<String, dynamic>> botCommands = [];

  @override
  void initState() {
    super.initState();
    loadBotCommands();
  }

  Future<void> loadBotCommands() async {
    String botCommandsResponse = await getClientBotCommands(widget.uid);

    final parsedData = json.decode(botCommandsResponse);

    if (parsedData.containsKey('botCommands') &&
        parsedData['botCommands'] is List) {
      setState(() {
        botCommands =
            List<Map<String, dynamic>>.from(parsedData['botCommands']);
      });
    }
  }

  Future<void> _refreshBotCommands() async {
    await loadBotCommands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.clientName}'s Bot Commands"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBotCommands,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: (botCommands.isNotEmpty)
                  ? ListView.builder(
                      itemCount: botCommands.length,
                      itemBuilder: (context, index) {
                        final commandEntry = botCommands[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 4.0,
                          child: ListTile(
                            title: Text('Datum: ${commandEntry["datum"]}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Uhrzeit: ${commandEntry["uhrzeit"]}'),
                                SizedBox(
                                  child: Text(
                                    'Command: ${commandEntry["command"]}',
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Es liegen keine Bot-Commands vor.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
