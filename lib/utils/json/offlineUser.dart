class OfflineUser {
  final String uid;
  final String name;

  const OfflineUser({
    required this.uid,
    required this.name,
  });

  static OfflineUser fromJson(json) => OfflineUser(
    uid: json['uid'],
    name: json['name'],
  );
}
