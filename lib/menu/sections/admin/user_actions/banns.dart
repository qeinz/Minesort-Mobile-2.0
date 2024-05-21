import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../utils/requests.dart';

class BansPage extends StatefulWidget {
  final String clientName;
  final String uid;

  const BansPage({
    required this.clientName,
    required this.uid,
    super.key,
  });

  @override
  _BansPageState createState() => _BansPageState();
}

class _BansPageState extends State<BansPage> {
  List<Map<String, dynamic>> bansLog = [];

  @override
  void initState() {
    super.initState();
    loadBansLog();
  }

  Future<void> loadBansLog() async {
    String bansLogResponse = await getClientsBanLog(widget.uid);

    final parsedData = json.decode(bansLogResponse);

    if (parsedData.containsKey('banns') && parsedData['banns'] is List) {
      setState(() {
        bansLog = List<Map<String, dynamic>>.from(parsedData['banns']);
      });
    }
  }

  Future<void> _refreshBansLog() async {
    await loadBansLog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.clientName}'s Bans Log"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBansLog,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: (bansLog.isNotEmpty)
                  ? ListView.builder(
                      itemCount: bansLog.length,
                      itemBuilder: (context, index) {
                        final logEntry = bansLog[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 4.0,
                          child: ListTile(
                            title: Text('Datum: ${logEntry["Datum"]}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Art: ${logEntry["Art"]}'),
                                Text('Author: ${logEntry["Author"]}'),
                                Text('Dauer: ${logEntry["Dauer"]}'),
                                Text('Uhrzeit: ${logEntry["Uhrzeit"]}'),
                                Text('Name: ${logEntry["Name"]}'),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Es liegen keine Bannprotokolle vor.',
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
