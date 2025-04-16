class ValidatedCommodity {
  final int id;
  final int zoneId;
  final int surveyId;
  final bool isSave;
  final bool isSubmit;
  final String? amount;
  final String? commodityExpiryDate;
  final String? availability;
  final String? commodityImageUrl;
  final Commoditysec? commodity;
  final Brandsec? brand;
  final Unitsec? unit;
  bool isEditable;

  ValidatedCommodity({
    required this.id,
    required this.zoneId,
    required this.surveyId,
    required this.isSave,
    required this.isSubmit,
    this.amount,
    this.commodityExpiryDate,
    this.availability,
    this.commodityImageUrl,
    this.commodity,
    this.brand,
    this.unit,
    this.isEditable = true,
  });

  factory ValidatedCommodity.fromJson(Map<String, dynamic> json) {
    return ValidatedCommodity(
      id: _parseInt(json['id']),
      zoneId: _parseInt(json['zone_id']),
      surveyId: _parseInt(json['survey_id']),
      isSave: json['is_save'] ?? false,
      isSubmit: json['is_submit'] ?? false,
      amount: json['amount']?.toString() ?? '',
      commodityExpiryDate: json['commodity_expiry_date']?.toString() ?? '',
      availability: json['availability']?.toString() ?? 'low',
      commodityImageUrl: json['commodity_image'],
      commodity: json['commodity'] != null
          ? Commoditysec.fromJson(json['commodity'])
          : null,
      brand: json['brand'] != null ? Brandsec.fromJson(json['brand']) : null,
      unit: json['unit'] != null ? Unitsec.fromJson(json['unit']) : null,
      isEditable: json['isEditable'] ?? true, // Added for offline loading
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'zone_id': zoneId,
        'survey_id': surveyId,
        'is_save': isSave,
        'is_submit': isSubmit,
        'amount': amount,
        'commodity_expiry_date': commodityExpiryDate,
        'availability': availability,
        'commodity_image': commodityImageUrl,
        'commodity': commodity?.toJson(),
        'brand': brand?.toJson(),
        'unit': unit?.toJson(),
        'isEditable': isEditable,
      };

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class Commoditysec {
  final int id;
  final String name;
  final int categoryId;
  final int brandId;
  final int uomId;
  final String unitValue;
  final String? image;
  final String status;
  final String createdAt;
  final String updatedAt;

  Commoditysec({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.brandId,
    required this.uomId,
    required this.unitValue,
    this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Commoditysec.fromJson(Map<String, dynamic> json) {
    return Commoditysec(
      id: ValidatedCommodity._parseInt(json['id']),
      name: json['name'] ?? '',
      categoryId: ValidatedCommodity._parseInt(json['category_id']),
      brandId: ValidatedCommodity._parseInt(json['brand_id']),
      uomId: ValidatedCommodity._parseInt(json['uom_id']),
      unitValue: json['unit_value'] ?? '',
      image: json['image'],
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category_id': categoryId,
        'brand_id': brandId,
        'uom_id': uomId,
        'unit_value': unitValue,
        'image': image,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class Brandsec {
  final int id;
  final String name;
  final String status;
  final String createdAt;
  final String updatedAt;

  Brandsec({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brandsec.fromJson(Map<String, dynamic> json) {
    return Brandsec(
      id: ValidatedCommodity._parseInt(json['id']),
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class Unitsec {
  final int id;
  final String name;
  final String status;
  final String createdAt;
  final String updatedAt;

  Unitsec({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Unitsec.fromJson(Map<String, dynamic> json) {
    return Unitsec(
      id: ValidatedCommodity._parseInt(json['id']),
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
