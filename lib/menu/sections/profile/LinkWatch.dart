import 'package:flutter/material.dart';

import '../../../utils/requests.dart'; // Add this import for HTTP requests

class LinkWatch extends StatelessWidget {
  final TextEditingController tokenController = TextEditingController();

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
        title: const Text('Link Watch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(labelText: 'Enter Token'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                sendToken(tokenController.text);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Link Watch Finish'),
                    content:
                        const Text('Deine Uhr wurde erfolgreich verbunden'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Send Token'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LinkWatch(),
  ));
}
