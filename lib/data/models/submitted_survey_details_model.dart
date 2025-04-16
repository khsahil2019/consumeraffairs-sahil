class SubmittedSurveyDetails {
  final int id;
  final String surveyId;
  final String name;
  final int zoneId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isComplete;
  final String status;
  final Zone zone;
  final List<Market> markets;

  SubmittedSurveyDetails({
    required this.id,
    required this.surveyId,
    required this.name,
    required this.zoneId,
    required this.startDate,
    required this.endDate,
    required this.isComplete,
    required this.status,
    required this.zone,
    required this.markets,
  });

  factory SubmittedSurveyDetails.fromJson(Map<String, dynamic> json) {
    return SubmittedSurveyDetails(
      id: json['id'] ?? 0,
      surveyId: json['survey_id'] ?? '',
      name: json['name'] ?? '',
      zoneId: json['zone_id'] ?? 0,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      isComplete: json['is_complete'] == 1,
      status: json['status']?.toString() ?? '0',
      zone: Zone.fromJson(json['zone'] ?? {}),
      markets: (json['markets'] as List<dynamic>?)
          ?.map((e) => Market.fromJson(e))
          .toList() ??
          [],
    );
  }
}



class Zone {
  final int id;
  final String name;

  Zone({required this.id, required this.name});

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
    );
  }
}


class Market {
  final String marketName;
  final List<Category> categories;

  Market({required this.marketName, required this.categories});

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      marketName: json['market_name'] ?? '',
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class Category {
  final String categoryName;
  final List<SurveyEntry> surveys;

  Category({required this.categoryName, required this.surveys});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryName: json['category_name'] ?? '',
      surveys: (json['surveys'] as List<dynamic>?)
          ?.map((e) => SurveyEntry.fromJson(e))
          .toList() ??
          [],
    );
  }
}


class SurveyEntry {
  final int id;
  final String amount;
  final String availability;
  final String? commodityImage;
  final String? commodityExpiryDate;
  final bool isSave;
  final bool isSubmit;
  final Commodity? commodity;
  final MarketInfo? market;
  final CategoryInfo? category;

  SurveyEntry({
    required this.id,
    required this.amount,
    required this.availability,
    this.commodityImage,
    this.commodityExpiryDate,
    required this.isSave,
    required this.isSubmit,
    this.commodity,
    this.market,
    this.category,
  });

  factory SurveyEntry.fromJson(Map<String, dynamic> json) {
    return SurveyEntry(
      id: json['id'] ?? 0,
      amount: json['amount']?.toString() ?? '',
      availability: json['availability'] ?? '',
      commodityImage: json['commodity_image'],
      commodityExpiryDate: json['commodity_expiry_date'],
      isSave: json['is_save'] == 1,
      isSubmit: json['is_submit'] == 1,
      commodity: json['commodity'] != null ? Commodity.fromJson(json['commodity']) : null,
      market: json['market'] != null ? MarketInfo.fromJson(json['market']) : null,
      category: json['category'] != null ? CategoryInfo.fromJson(json['category']) : null,
    );
  }
}




class Commodity {
  final int id;
  final String name;
  final String? unitValue;
  final String? image;
  final Brand? brand;
  final Uom? uom;

  Commodity({
    required this.id,
    required this.name,
    this.unitValue,
    this.image,
    this.brand,
    this.uom,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      unitValue: json['unit_value'],
      image: json['image'],
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
      uom: json['uom'] != null ? Uom.fromJson(json['uom']) : null,
    );
  }
}
class Brand {
  final int id;
  final String name;

  Brand({
    required this.id,
    required this.name,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
    );
  }
}
class Uom {
  final int id;
  final String name;

  Uom({
    required this.id,
    required this.name,
  });

  factory Uom.fromJson(Map<String, dynamic> json) {
    return Uom(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
    );
  }
}





class MarketInfo {
  final int id;
  final String name;
  final String zoneName;
  final String image;

  MarketInfo({
    required this.id,
    required this.name,
    required this.zoneName,
    required this.image,
  });

  factory MarketInfo.fromJson(Map<String, dynamic> json) {
    return MarketInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      zoneName: json['zone_name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class CategoryInfo {
  final int id;
  final String name;
  final String image;

  CategoryInfo({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

