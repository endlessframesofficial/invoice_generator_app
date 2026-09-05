class CompanyInfo {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String? logoUrl;
  final String? signatureUrl;
  final String? signatureType;

  const CompanyInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    this.logoUrl,
    this.signatureUrl,
    this.signatureType,
  });

  CompanyInfo copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
    String? signatureUrl,
    String? signatureType,
  }) {
    return CompanyInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      signatureType: signatureType ?? this.signatureType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (signatureUrl != null) 'signatureUrl': signatureUrl,
      if (signatureType != null) 'signatureType': signatureType,
    };
  }

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      signatureUrl: json['signatureUrl'] as String?,
      signatureType: json['signatureType'] as String?,
    );
  }
}
