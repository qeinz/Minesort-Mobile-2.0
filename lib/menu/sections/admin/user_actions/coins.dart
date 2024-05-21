import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../utils/requests.dart';

class CoinsPage extends StatefulWidget {
  final String clientName;
  final String coins;
  final String uid;

  const CoinsPage({
    required this.clientName,
    required this.coins,
    required this.uid,
    super.key,
  });

  @override
  _CoinsPageState createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  List<Map<String, dynamic>> coinsLog = [];
  String selectedAmount = "0"; // Default amount

  @override
  void initState() {
    super.initState();
    loadCoinsLog();
  }

  Future<void> loadCoinsLog() async {
    String coinsLogResponse = await getClientsCoinsLog(widget.uid);

    final parsedData = json.decode(coinsLogResponse);

    if (parsedData.containsKey('coinslog') && parsedData['coinslog'] is List) {
      setState(() {
        coinsLog = List<Map<String, dynamic>>.from(parsedData['coinslog']);
      });
    }
  }

  Future<void> _refreshCoinsLog() async {
    await loadCoinsLog();
  }

  void _openAddCoinsDialog(BuildContext context) {
    String selectedOperation = "set"; // Default operation

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Coins bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Anzahl'),
                onChanged: (value) {
                  setState(() {
                    selectedAmount = value;
                  });
                },
              ),
              DropdownButton<String>(
                value: selectedOperation,
                items: <String>['set', 'add', 'remove'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOperation = newValue ?? "set";
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Senden'),
              onPressed: () async {
                // Handle adding coins here
                final response = await editCoinsClient(
                    widget.uid, selectedAmount, selectedOperation);
                if (response == "Ausgeführt") {
                  showSuccessSnackbar("Aktion erfolgreich ausgeführt.");
                } else {
                  showErrorSnackbar("Fehler beim Ausführen der Aktion.");
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.clientName} • [${widget.coins} Coins]"),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_money),
            onPressed: () {
              _openAddCoinsDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCoinsLog,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: (coinsLog.isNotEmpty)
                  ? ListView.builder(
                      itemCount: coinsLog.length,
                      itemBuilder: (context, index) {
                        final logEntry = coinsLog[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 4.0,
                          child: ListTile(
                            title: Text('Datum: ${logEntry["datum"]}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Uhrzeit: ${logEntry["uhrzeit"]}'),
                                Text('Betrag: ${logEntry["amount"]}'),
                                Text('Option: ${logEntry["option"]}'),
                                Text('Status: ${logEntry["status"]}'),
                                Text('Fehlercode: ${logEntry["error_code"]}'),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Es liegen keine Coins-Logdaten vor.',
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
