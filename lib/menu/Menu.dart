import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minesort/menu/sections/Admin.dart';
import 'package:minesort/menu/sections/Chat.dart';
import 'package:minesort/menu/sections/Profile.dart';
import 'package:minesort/utils/requests.dart';

class _TabInfo {
  const _TabInfo(this.title, this.icon, this.selectedIcon);

  final String title;
  final IconData icon;
  final IconData selectedIcon;
}

class CupertinoTabBarDemo extends StatefulWidget {
  const CupertinoTabBarDemo({super.key});

  @override
  _CupertinoTabBarDemoState createState() => _CupertinoTabBarDemoState();
}

class _CupertinoTabBarDemoState extends State<CupertinoTabBarDemo> {
  int selectedIndex = 0; // Index des ausgewählten Tabs
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;
  List<_TabInfo> tabInfo = [];

  @override
  Widget build(BuildContext context) {
    if (apikey != "ERROR") {
      tabInfo = [
        const _TabInfo(
            "Admin", CupertinoIcons.hammer, CupertinoIcons.hammer_fill),
        const _TabInfo("Chat", CupertinoIcons.chat_bubble_2,
            CupertinoIcons.chat_bubble_2_fill),
        const _TabInfo(
            "Profile", CupertinoIcons.person, CupertinoIcons.person_fill)
      ];
    } else {
      tabInfo = [
        const _TabInfo("Chat", CupertinoIcons.chat_bubble_2,
            CupertinoIcons.chat_bubble_2_fill),
        const _TabInfo(
            "Profile", CupertinoIcons.person, CupertinoIcons.person_fill)
      ];
    }
    if (android) {
      return androidMenu();
    } else {
      return normalMenu();
    }
  }

  normalMenu() {
    if (apikey != "ERROR") {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: selectedIndex,
          onTap: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.hammer),
              activeIcon: Icon(CupertinoIcons.hammer_fill),
              label: 'Admin',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_2),
              activeIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
              label: 'Profile',
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (BuildContext context) {
              return SafeArea(
                child: _CupertinoDemoTab(
                  title: tabInfo[index].title,
                  icon: tabInfo[index].icon,
                ),
              );
            },
          );
        },
      );
    } else {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: selectedIndex,
          onTap: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_2),
              activeIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
              label: 'Profile',
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (BuildContext context) {
              return _CupertinoDemoTab(
                title: tabInfo[index].title,
                icon: tabInfo[index].icon,
              );
            },
          );
        },
      );
    }
  }

  androidMenu() {
    if (apikey != "ERROR") {
      return Scaffold(
        body: _CupertinoDemoTab(
          title: tabInfo[selectedIndex].title,
          icon: tabInfo[selectedIndex].icon,
        ),
        bottomNavigationBar: NavigationBar(
          labelBehavior: labelBehavior,
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(CupertinoIcons.hammer_fill),
              icon: Icon(CupertinoIcons.hammer),
              label: 'Admin',
            ),
            NavigationDestination(
              selectedIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
              icon: Icon(CupertinoIcons.chat_bubble_2),
              label: 'Chat',
            ),
            NavigationDestination(
              selectedIcon: Icon(CupertinoIcons.person_fill),
              icon: Icon(CupertinoIcons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: _CupertinoDemoTab(
          title: tabInfo[selectedIndex].title,
          icon: tabInfo[selectedIndex].icon,
        ),
        bottomNavigationBar: NavigationBar(
          labelBehavior: labelBehavior,
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
              icon: Icon(CupertinoIcons.chat_bubble_2),
              label: 'Chat',
            ),
            NavigationDestination(
              selectedIcon: Icon(CupertinoIcons.person_fill),
              icon: Icon(CupertinoIcons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    }
  }
}

class _CupertinoDemoTab extends StatefulWidget {
  const _CupertinoDemoTab({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  State<_CupertinoDemoTab> createState() => _CupertinoDemoTabState();
}

class _CupertinoDemoTabState extends State<_CupertinoDemoTab> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _buildTabContent(),
    );
  }

  Widget _buildTabContent() {
    switch (widget.title) {
      case "Profile":
        return const Profile();

      case "Chat":
        return const Chat();

      case "Admin":
        return const Admin();

      default:
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(),
          backgroundColor: CupertinoColors.systemBackground,
          child: Center(
            child: Icon(
              widget.icon,
              semanticLabel: widget.title,
              size: 100,
            ),
          ),
        );
    }
  }
}
