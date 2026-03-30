class VaultItem {
  final String id;
  final String title;
  final String encryptedData;
  final String nonce;
  final String mac;

  VaultItem({
    required this.id,
    required this.title,
    required this.encryptedData,
    required this.nonce,
    required this.mac,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'encryptedData': encryptedData,
      'nonce': nonce,
      'mac': mac,
    };
  }

  factory VaultItem.fromMap(Map<String, dynamic> map) {
    return VaultItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      encryptedData: map['encryptedData'] ?? '',
      nonce: map['nonce'] ?? '',
      mac: map['mac'] ?? '',
    );
  }

  VaultItem copyWith({
    String? id,
    String? title,
    String? encryptedData,
    String? nonce,
    String? mac,
  }) {
    return VaultItem(
      id: id ?? this.id,
      title: title ?? this.title,
      encryptedData: encryptedData ?? this.encryptedData,
      nonce: nonce ?? this.nonce,
      mac: mac ?? this.mac,
    );
  }
}