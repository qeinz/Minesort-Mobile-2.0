import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../utils/requests.dart';

class LastChannelsPage extends StatefulWidget {
  final String clientName;
  final String uid;

  const LastChannelsPage({
    required this.clientName,
    required this.uid,
    super.key,
  });

  @override
  _LastChannelsPageState createState() => _LastChannelsPageState();
}

class _LastChannelsPageState extends State<LastChannelsPage> {
  List<Map<String, dynamic>> lastChannels = [];

  @override
  void initState() {
    super.initState();
    loadLastChannels();
  }

  Future<void> loadLastChannels() async {
    String lastChannelsResponse = await getClientLastChannels(widget.uid);

    final parsedData = json.decode(lastChannelsResponse);

    if (parsedData.containsKey('lastChannels') &&
        parsedData['lastChannels'] is List) {
      setState(() {
        lastChannels =
            List<Map<String, dynamic>>.from(parsedData['lastChannels']);
      });
    }
  }

  Future<void> _refreshLastChannels() async {
    await loadLastChannels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.clientName}'s Last Channels"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLastChannels,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: (lastChannels.isNotEmpty)
                  ? ListView.builder(
                      itemCount: lastChannels.length,
                      itemBuilder: (context, index) {
                        final channelEntry = lastChannels[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 4.0,
                          child: ListTile(
                            title: Text(
                                'Datum: ${_formatDate(channelEntry["time"])}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Uhrzeit: ${_formatTime(channelEntry["time"])}'),
                                Text(
                                    'Channel: ${channelEntry["channel_name"]}'),
                                Text(
                                    'Channel ID: ${channelEntry["channel_id"]}'),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Es liegen keine Daten über die letzten Channels vor.',
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

  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final formatter = DateFormat('dd.MM.yyyy');
    return formatter.format(dateTime);
  }

  String _formatTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final formatter = DateFormat('HH:mm:ss');
    return formatter.format(dateTime);
  }
}
