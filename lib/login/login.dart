import 'package:flutter/material.dart';
import 'package:minesort/utils/requests.dart';
import 'package:minesort/menu/Menu.dart';

class login extends StatelessWidget {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minesort Mobile"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Image.asset(
              'assets/appicon.png',
              width: 100,
              height: 100,
            )),
            const Padding(
              padding: EdgeInsets.only(top: 50),
              // add 16 pixels of padding to the top
              child: Text(
                'Enter your login token\n'
                '\t» from your email\n\n'
                'You have problems? \n'
                '\t» write app@minesort.de\n',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Token',
                    suffixIcon: IconButton(
                      onPressed: () {
                        _textController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    )),
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              icon: const Icon(Icons.login),
              label: const Text("Login"),
              onPressed: () async {
                var response = await checkToken(_textController.text);
                if (response.body != "false" && response.body != "") {
                  await savesToken(response.body);
                  await getApiKey(response.body);
                  await getUid();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const CupertinoTabBarDemo()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Wrong Token"),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
