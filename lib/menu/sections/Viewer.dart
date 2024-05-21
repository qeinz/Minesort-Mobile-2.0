/*import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Viewer extends StatefulWidget {
  const Viewer({Key? key}) : super(key: key);

  @override
  State<Viewer> createState() => __TabsScrollableDemoState();
}

class __TabsScrollableDemoState extends State<Viewer>
    with SingleTickerProviderStateMixin, RestorationMixin {
  TabController? _tabController;

  final RestorableInt tabIndex = RestorableInt(0);

  @override
  String get restorationId => 'tab_scrollable_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(tabIndex, 'tab_index');
    _tabController!.index = tabIndex.value;
  }

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 0,
      length: 12,
      vsync: this,
    );
    _tabController!.addListener(() {
      // When the tab controller's value is updated, make sure to update the
      // tab index value, which is state restorable.

      setState(() {
        tabIndex.value = _tabController!.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    tabIndex.dispose();
    super.dispose();
  }

  Stack web(String url) {
    var controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (!request.url.startsWith(url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    return Stack(
        children: [
          Scaffold(
            body: WebViewWidget(controller: controller),
          ),
        ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final Map<String, String> sites = {
      "Stats": "https://stats.minesort.de/stats/",
      "Ts3": "https://app.minesort.de/server_viewer_light.html",
      "Discord": "https://canary.discord.com/widget?id=778340849414438944&theme=dark",
      "Network": "https://stats.uptimerobot.com/QgWrDI6n9W",
    };

    return DefaultTabController(
      length: sites.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              for (final tab in sites.keys)
                Tab(text: tab),
            ],
          ),
        ),
        backgroundColor: CupertinoColors.systemBackground,
        body: TabBarView(
          children: [
            for (final site in sites.values)
              Center(
                child: web(site),
              ),
          ],
        ),
      ),
    );

  }



// @override
  // Widget build(BuildContext context) {
  //   final Map<String, String> sites = HashMap();
  //   sites["Stats"] = "https://stats.minesort.de/stats/";
  //   sites["Ts3"] = "https://app.minesort.de/server_viewer_light.html";
  //   sites["Discord"] =
  //   "https://canary.discord.com/widget?id=778340849414438944&theme=dark";
  //   sites['Network'] = "https://stats.uptimerobot.com/QgWrDI6n9W";
  //
  //   return Scaffold(
  //     appBar: const CupertinoNavigationBar(
  //       middle: Text("Viewer"),
  //     ),
  //     body: TabBarView(
  //       controller: _tabController,
  //       children: [
  //         for (final tab in sites.keys)
  //           Center(
  //             child: web(sites[tab]!),
  //           )
  //       ],
  //     ),
  //     bottomNavigationBar: Material(
  //       color: Colors.blue,
  //       child: TabBar(
  //         controller: _tabController,
  //         tabs: [
  //           for (final tab in sites.keys) Tab(text: tab),
  //         ],
  //       ),
  //     ),
  //   );
  // }


}
*/
