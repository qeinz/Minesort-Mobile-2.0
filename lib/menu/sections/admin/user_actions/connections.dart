import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../utils/requests.dart';

class ConnectionsPage extends StatefulWidget {
  final String clientName;
  final String uid;

  const ConnectionsPage({
    required this.clientName,
    required this.uid,
    super.key,
  });

  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  List<Map<String, dynamic>> connectionsLog = [];

  @override
  void initState() {
    super.initState();
    loadConnectionsLog();
  }

  Future<void> loadConnectionsLog() async {
    String connectionsLogResponse = await getClientsConnectionsLog(widget.uid);

    final parsedData = json.decode(connectionsLogResponse);

    if (parsedData.containsKey('connections') &&
        parsedData['connections'] is List) {
      setState(() {
        connectionsLog =
            List<Map<String, dynamic>>.from(parsedData['connections']);
      });
    }
  }

  Future<void> _refreshConnectionsLog() async {
    await loadConnectionsLog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.clientName}'s Connections Log"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshConnectionsLog,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: (connectionsLog.isNotEmpty)
                  ? ListView.builder(
                      itemCount: connectionsLog.length,
                      itemBuilder: (context, index) {
                        final logEntry = connectionsLog[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 4.0,
                          child: ListTile(
                            title: Text('Datum: ${logEntry["datum"]}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Uhrzeit: ${logEntry["uhrzeit"]}'),
                                Text('Typ: ${logEntry["type"]}'),
                                Text('Plattform: ${logEntry["platform"]}'),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Es liegen keine Verbindungsprotokolle vor.',
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
