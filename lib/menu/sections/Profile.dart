import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minesort/menu/sections/profile/LinkWatch.dart';
import 'package:minesort/utils/requests.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<StatefulWidget> createState() => _CupertinoDemoTabState();
}

class _CupertinoDemoTabState extends State<Profile> with RestorationMixin {
  late Future<String> _profileFuture;
  final RestorableInt _selectedIndex = RestorableInt(0);

  @override
  String get restorationId => 'nav_rail_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedIndex, 'selected_index');
  }

  @override
  void initState() {
    super.initState();
    _profileFuture = getInfosFromApp();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      _profileFuture = getInfosFromApp();
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            centerTitle: true,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Account'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          // Ändere den Abstand nach Bedarf
          child: TabBarView(
            children: [
              AccountTab(_profileFuture),
              const SettingsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountTab extends StatefulWidget {
  final Future<String> profileFuture;

  const AccountTab(this.profileFuture, {super.key});

  @override
  _AccountTabState createState() => _AccountTabState(profileFuture);
}

class _AccountTabState extends State<AccountTab> {
  final Future<String> profileFuture;
  late RefreshController _refreshController;

  _AccountTabState(this.profileFuture) {
    _refreshController = RefreshController(initialRefresh: false);
  }

  Future<void> _onRefresh() async {
    await getInfosFromApp();
    if (mounted) {
      _refreshController.refreshCompleted();
    }
  }

  double imageSize = 210.0;

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: FutureBuilder<String>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final dataParts = snapshot.data.toString().split(',');
            final int coins = int.parse(dataParts[3].toString());
            NumberFormat formatter = NumberFormat.decimalPattern();
            String formattedNumber = formatter.format(coins);

            if (newDesignAccount) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background Image (1/3 of the display)
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/background_image.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Profile Image
                  Positioned(
                    top: 30,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          imageSize = (imageSize == 210.0) ? 250.0 : 210.0;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: imageSize,
                        width: imageSize,
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://stats.minesort.de/avatars/${dataParts[10]}.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return ClipOval(
                                child: Image.asset(
                                  'assets/images/profile.png',
                                  height: imageSize,
                                  width: imageSize,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Name (Moved below the profile picture)
                  Positioned(
                    top: MediaQuery.of(context).size.height / 3 - 10,
                    child: Text(
                      dataParts[1],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // User Statistics
                  Positioned(
                    top: MediaQuery.of(context).size.height / 3 + 60,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildStatColumn(
                              Icons.attach_money,
                              'Coins',
                              formattedNumber,
                            ),
                          ),
                          Expanded(
                            child: _buildStatColumn(
                              Icons.star,
                              'Rank',
                              dataParts[8],
                            ),
                          ),
                          Expanded(
                            child: _buildStatColumn(
                              Icons.account_tree,
                              'Connections',
                              dataParts[9],
                            ),
                          ),
                          // Add more Expanded widgets as needed
                        ],
                      ),
                    ),
                  ),
                  // Divider line
                  Positioned(
                    top: MediaQuery.of(context).size.height / 3 + 120,
                    child: Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                    ),
                  ),
                  // UID
                  Positioned(
                    top: MediaQuery.of(context).size.height / 3 + 140,
                    child: Text(
                      'UID: ${dataParts[0]}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Text about the user
                  Positioned(
                    top: MediaQuery.of(context).size.height / 3 + 170,
                    child: const Text(
                      'Text about the user goes here...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              const double leftValue = 35;
              const double iconSize = 28;
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (imageSize == 210.0) {
                          imageSize = 300.0;
                        } else {
                          imageSize = 210.0;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: imageSize,
                      width: imageSize,
                      curve: Curves.easeInOut,
                      child: ClipOval(
                        child: Image.network(
                          'https://stats.minesort.de/avatars/${dataParts[10]}.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return ClipOval(
                              child: Image.asset(
                                'assets/images/profile.png',
                                height: imageSize,
                                width: imageSize,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: leftValue),
                    child: Row(
                      children: [
                        const Tooltip(
                          message: 'Your Ts3-Client Nickname',
                          child: Icon(Icons.person_outline_outlined,
                              size: iconSize),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(width: 8),
                        Text(dataParts[1],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: leftValue),
                    child: Row(
                      children: [
                        const Tooltip(
                          message: 'Your Ts3-Client rank',
                          child:
                              Icon(Icons.star_border_outlined, size: iconSize),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(width: 8),
                        Text(dataParts[8]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: leftValue),
                    child: Row(
                      children: [
                        const Tooltip(
                          message: 'Your Ts3-Client coins',
                          child:
                              Icon(Icons.attach_money_outlined, size: iconSize),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(width: 8),
                        Text(formattedNumber),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: leftValue),
                    child: Row(
                      children: [
                        const Tooltip(
                          message: 'Your Ts3-Client register date',
                          child: Icon(Icons.verified_outlined, size: iconSize),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(width: 8),
                        Text(dataParts[5]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: leftValue),
                    child: Row(
                      children: [
                        const Tooltip(
                          message: 'Your Ts3-Client total connections',
                          child:
                              Icon(Icons.account_tree_outlined, size: iconSize),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(width: 8),
                        Text(dataParts[9]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: leftValue),
                    child: Row(
                      children: [
                        const Tooltip(
                          message: 'Your last Ts3-Client login',
                          child: Icon(Icons.connect_without_contact_outlined,
                              size: iconSize),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(width: 8),
                        Text(dataParts[7]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: leftValue),
                    child: Row(
                      children: [
                        const Tooltip(
                          message: 'Your Ts3-Client UID',
                          child: Icon(Icons.badge_outlined, size: iconSize),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(width: 8),
                        Text(dataParts[0]),
                      ],
                    ),
                  ),
                ],
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, String title, String value) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // Adjust the horizontal spacing
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold, // Bold for the numbers
                  color: Colors.white),
            ),
            const SizedBox(height: 8), // Increased vertical spacing
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18, // Font size for the titles
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

enum _Theme { system, white, dark }

class _SettingsTabState extends State<SettingsTab> {
  _Theme _ThemeView = _Theme.values[theme];
  int switchValue = theme;
  int admin = 0;
  double _currentSliderValue = chatLength.toDouble();

  @override
  @override
  Widget build(BuildContext context) {
    if (!android) {
      return CupertinoPageScaffold(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoButton.filled(
              onPressed: () {
                savesToken("");
                SystemNavigator.pop();
              },
              child: const Text('Logout'),
            ),
            const SizedBox(height: 16),
            // Replace CupertinoPicker with CupertinoSegmentedControl
            const Text('Erscheinungsbild:'),
            const SizedBox(height: 16),
            CupertinoSegmentedControl(
              groupValue: theme,
              onValueChanged: (int value) {
                setState(() {
                  theme = value;
                  savesTheme(value);
                });
              },
              children: const {
                0: Text('System'),
                1: Text('White'),
                2: Text('Dark'),
              },
            ),
            const SizedBox(height: 16),
            const Text("Chat Länge"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: CupertinoSlider(
                value: _currentSliderValue,
                min: 10,
                max: 100,
                divisions: 100,
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                    saveChatLength(value.toInt());
                  });
                },
              ),
            ),

            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LinkWatch(),
                  ),
                );
              },
              child: const Text("LinkWatch"),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Android Design:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                CupertinoSwitch(
                  // This bool value toggles the switch.
                  value: android,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      android = value;
                      saveAndroid(android);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Neues Design in Account:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                CupertinoSwitch(
                  // This bool value toggles the switch.
                  value: newDesignAccount,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      newDesignAccount = value;
                      saveNewDesign(newDesignAccount);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: () {
              savesToken("");
              SystemNavigator.pop();
            },
            child: const Text('Logout'),
          ),
          const SizedBox(height: 16),
          // Replace CupertinoPicker with CupertinoSegmentedControl
          const Text('Erscheinungsbild:'),
          const SizedBox(height: 16),
          SegmentedButton<_Theme>(
            segments: const <ButtonSegment<_Theme>>[
              ButtonSegment<_Theme>(
                  value: _Theme.system,
                  label: Text('System'),
                  icon: Icon(Icons.system_security_update)),
              ButtonSegment<_Theme>(
                  value: _Theme.white,
                  label: Text('White'),
                  icon: Icon(Icons.calendar_view_month)),
              ButtonSegment<_Theme>(
                  value: _Theme.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.calendar_today)),
            ],
            selected: <_Theme>{_ThemeView},
            onSelectionChanged: (Set<_Theme> newSelection) {
              setState(() {
                // By default there is only a single segment that can be
                // selected at one time, so its value is always the first
                // item in the selected set.
                _ThemeView = newSelection.first;
                savesTheme(newSelection.first.index);
              });
            },
          ),

          const SizedBox(height: 16),
          const Text("Chat Länge"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Slider(
              value: _currentSliderValue,
              min: 10,
              max: 100,
              divisions: 100,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                  saveChatLength(value.toInt());
                });
              },
            ),
          ),

          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LinkWatch(),
                ),
              );
            },
            child: const Text("LinkWatch"),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Android Design:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Switch(
                // This bool value toggles the switch.
                value: android,
                activeColor: Colors.red,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    android = value;
                    saveAndroid(android);
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Neues Design in Account:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Switch(
                // This bool value toggles the switch.
                value: newDesignAccount,
                activeColor: Colors.red,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    newDesignAccount = value;
                    saveNewDesign(newDesignAccount);
                  });
                },
              ),
            ],
          ),
        ],
      );
    }
  }
}
