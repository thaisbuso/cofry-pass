class DecryptedVaultItem {
  final String username;
  final String password;
  final String? url;
  final String? notes;

  DecryptedVaultItem({
    required this.username,
    required this.password,
    this.url,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
    };
  }

  factory DecryptedVaultItem.fromMap(Map<String, dynamic> map) {
    return DecryptedVaultItem(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      url: map['url'],
      notes: map['notes'],
    );
  }
}