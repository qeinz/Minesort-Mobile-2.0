import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minesort/utils/requests.dart';

class Badword extends StatefulWidget {
  const Badword({super.key});

  @override
  _BadwordPopupState createState() => _BadwordPopupState();
}

class _BadwordPopupState extends State<Badword> {
  late List<String?> badwordsList;
  String? world;
  late TextEditingController _textController;
  late TextEditingController _textController2;
  late List<String?> filteredList;
  bool systemEnabled = true; // Add a boolean variable to track system status

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController2 = TextEditingController();
    badwordsList = [];
    filteredList = [];
    updateBwords();
    test();
  }

  Future<void> test() async {
    systemEnabled = await getBadwordsStatus();
  }

  final ScrollController _scrollController = ScrollController();

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
        title: const Text('Badwords'),
        actions: [
          Switch(
            value: systemEnabled,
            onChanged: (value) {
              setState(() {
                systemEnabled = value;
                setBotStatus(value.toString());
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBadwordDialog(),
        child: const Icon(Icons.add),
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
                await updateBwords();
              },
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredList[index]!),
                      onTap: () => _showDeleteDialog(filteredList[index]),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBadwordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Badword'),
          content: TextField(
            controller: _textController2,
            decoration: const InputDecoration(labelText: 'Badword'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                addBadword(_textController2.text);
                _textController2.clear();
                _textController.clear();
                Navigator.pop(context);
                updateBwords();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String? word) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Badword'),
          content: Text('Do you want to delete the badword "$word"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                removeBadword(word!);
                Navigator.pop(context);
                updateBwords();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _filterList(String query) {
    setState(() {
      filteredList = badwordsList
          .where((word) =>
              word != null && word.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> updateBwords() async {
    List<String?> updatedList = await getBadwordsList();
    setState(() {
      badwordsList = updatedList.reversed.toList();
      filteredList = badwordsList;
    });
    test();
  }

  Future<void> addBadword(String word) async {
    await http.get(Uri.https(backendURL, '/security/badwords',
        {'apikey': apikey, 'word': word, 'operation': 'add'}));
    await updateBwords();
  }

  Future<void> removeBadword(String word) async {
    await http.get(Uri.https(backendURL, '/security/badwords',
        {'apikey': apikey, 'word': word, 'operation': 'remove'}));
    await updateBwords();
  }
}
