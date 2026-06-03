class CompanyInfo {
  final String name;
  final String address;
  final String phone;
  final String email;

  const CompanyInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });

  CompanyInfo copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
  }) {
    return CompanyInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
    };
  }

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}
