class User {
  final int clientID;
  final int coins;
  final String ip;
  final String version;
  final int idleTime;
  final String platform;
  final String uid;
  final bool isTeamler;
  final String nickname;
  final String land;
  final bool hasBanns;
  final bool hasConnections;
  final bool isRegistered;
  final int channelID;
  final int connections;

  const User({
    required this.clientID,
    required this.coins,
    required this.ip,
    required this.version,
    required this.idleTime,
    required this.platform,
    required this.uid,
    required this.isTeamler,
    required this.nickname,
    required this.land,
    required this.hasBanns,
    required this.hasConnections,
    required this.isRegistered,
    required this.channelID,
    required this.connections,
  });

  static User fromJson(json) => User(
        clientID: json['clientID'],
        coins: json['coins'],
        ip: json['ip'],
        version: json['version'],
        idleTime: json['idleTime'],
        platform: json['platform'],
        uid: json['uid'],
        isTeamler: json['isTeamler'],
        nickname: json['nickname'],
        land: json['land'],
        hasBanns: json['hasBanns'],
        hasConnections: json['hasConnections'],
        isRegistered: json['isRegistered'],
        channelID: json['channelID'],
        connections: json['connections'],
      );
}
