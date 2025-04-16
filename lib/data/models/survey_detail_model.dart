class SurveyDetail {
  final int id;
  final String? surveyId;
  final String name;
  final int zoneId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isComplete;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ZoneInfo zone;
  final List<GenericItem> markets;
  final List<Category> categories;

  SurveyDetail({
    required this.id,
    required this.surveyId,
    required this.name,
    required this.zoneId,
    required this.startDate,
    required this.endDate,
    required this.isComplete,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.zone,
    required this.markets,
    required this.categories,
  });

  factory SurveyDetail.fromJson(Map<String, dynamic> json) {
    return SurveyDetail(
      id: json['id'],
      surveyId: json['survey_id'],
      name: json['name'],
      zoneId: json['zone_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isComplete: json['is_complete'] == 1,
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      zone: ZoneInfo.fromJson(json['zone']),
      markets: (json['markets'] as List<dynamic>)
          .map((e) => GenericItem.fromJson(e))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => Category.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'survey_id': surveyId,
        'name': name,
        'zone_id': zoneId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_complete': isComplete ? 1 : 0,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'zone': zone.toJson(),
        'markets': markets.map((m) => m.toJson()).toList(),
        'categories': categories.map((c) => c.toJson()).toList(),
      };
}

class ZoneInfo {
  final int id;
  final String name;

  ZoneInfo({required this.id, required this.name});

  factory ZoneInfo.fromJson(Map<String, dynamic> json) {
    return ZoneInfo(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class GenericItem {
  final int id;
  final String name;

  GenericItem({required this.id, required this.name});

  factory GenericItem.fromJson(Map<String, dynamic> json) {
    return GenericItem(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class Category {
  final int id;
  final String name;
  final List<Commodity> commodities;

  Category({required this.id, required this.name, required this.commodities});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      commodities: (json['commodities'] as List<dynamic>)
          .map((e) => Commodity.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'commodities': commodities.map((c) => c.toJson()).toList(),
      };
}

class Commodity {
  final int id;
  final String name;
  final int? categoryId;
  final int? brandId;
  final int? uomId;
  final String? unitValue;
  final String? image;
  final String? status;
  final Brand? brand;
  final Uom? uom;

  Commodity({
    required this.id,
    required this.name,
    this.categoryId,
    this.brandId,
    this.uomId,
    this.unitValue,
    this.image,
    this.status,
    this.brand,
    this.uom,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'],
      brandId: json['brand_id'],
      uomId: json['uom_id'],
      unitValue: json['unit_value'],
      image: json['image'],
      status: json['status'],
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
      uom: json['uom'] != null ? Uom.fromJson(json['uom']) : null,
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
        'brand': brand?.toJson(),
        'uom': uom?.toJson(),
      };
}

class Brand {
  final int id;
  final String name;

  Brand({required this.id, required this.name});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class Uom {
  final int id;
  final String name;

  Uom({required this.id, required this.name});

  factory Uom.fromJson(Map<String, dynamic> json) {
    return Uom(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
