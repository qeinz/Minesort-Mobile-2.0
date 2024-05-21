class Contact {
  final int pairId;
  final String name;
  final String uid;
  final String hashedUid;

  const Contact({
    required this.pairId,
    required this.name,
    required this.uid,
    required this.hashedUid,
  });

  static Contact fromJson(json) => Contact(
        pairId: json['pairid'],
        name: json['name'],
        uid: json['uid'],
        hashedUid: json['hasheduid'],
      );
}
