import 'package:flutter/material.dart';
import 'package:minesort/menu/sections/admin/user.dart';
import 'dart:convert';
import 'package:minesort/utils/requests.dart';

class Client {
  String uid;
  String username;

  Client({required this.uid, required this.username});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      uid: json['uid'] as String,
      username: json['username'] as String,
    );
  }
}

class OfflineUser extends StatefulWidget {
  const OfflineUser({super.key});

  @override
  _OfflineUserPopupState createState() => _OfflineUserPopupState();
}

List<Client> clientsList = [];
List<Client> filteredList = [];

class _OfflineUserPopupState extends State<OfflineUser> {
  late TextEditingController _textController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Offline Clients'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                _filterList(query);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await updateBwords(true);
              },
              child: FutureBuilder<void>(
                future: updateBwords(false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading data'),
                    );
                  } else {
                    return Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filteredList[index].username),
                            onTap: () => {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UserDetailPage(
                                    clientName: filteredList[index].username,
                                    clientUid: filteredList[index].uid,
                                  ),
                                ),
                              )
                            },
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _filterList(String query) {
    setState(() {
      filteredList = clientsList
          .where((client) =>
          client.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> updateBwords(bool force) async {
    if(force) {
      final String jsonResponse = await getOfflineUser();
      final Map<String, dynamic> parsedJson = json.decode(jsonResponse);

      setState(() {
        clientsList = (parsedJson['clients'] as List)
            .map((clientJson) => Client.fromJson(clientJson))
            .toList();
        filteredList = clientsList;
      });
    } else {
      if (clientsList.length < 1) {
        final String jsonResponse = await getOfflineUser();
        final Map<String, dynamic> parsedJson = json.decode(jsonResponse);

        setState(() {
          clientsList = (parsedJson['clients'] as List)
              .map((clientJson) => Client.fromJson(clientJson))
              .toList();
          filteredList = clientsList;
        });
      } else {
        filteredList = clientsList;
      }
    }
  }
}
