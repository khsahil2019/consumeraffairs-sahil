class AssignedCommodityModel {
  final int id;
  final int userId;
  final int zoneId;
  final int surveyId;
  final int marketId;
  final int categoryId;
  final int commodityId;
  final int? unitId;
  final int? brandId;
  final String? amount;
  final String? availability;
  final String? commodityImage;
  final int submittedBy;
  final int? updatedBy;
  final String status;
  final String publish;
  final String? commodityExpiryDate;
  final String createdAt;
  final String updatedAt;
  final bool isSave;
  final bool isSubmit;
  final AssignedCommodityDetail commodity;

  AssignedCommodityModel({
    required this.id,
    required this.userId,
    required this.zoneId,
    required this.surveyId,
    required this.marketId,
    required this.categoryId,
    required this.commodityId,
    required this.unitId,
    required this.brandId,
    required this.amount,
    required this.availability,
    required this.commodityImage,
    required this.submittedBy,
    required this.updatedBy,
    required this.status,
    required this.publish,
    required this.commodityExpiryDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isSave,
    required this.isSubmit,
    required this.commodity,
  });

  factory AssignedCommodityModel.fromJson(Map<String, dynamic> json) {
    return AssignedCommodityModel(
      id: json['id'],
      userId: json['user_id'],
      zoneId: json['zone_id'],
      surveyId: json['survey_id'],
      marketId: json['market_id'],
      categoryId: json['category_id'],
      commodityId: json['commodity_id'],
      unitId: json['unit_id'],
      brandId: json['brand_id'],
      amount: json['amount'],
      availability: json['availability'],
      commodityImage: json['commodity_image'],
      submittedBy: json['submitted_by'],
      updatedBy: json['updated_by'],
      status: json['status'],
      publish: json['publish'],
      commodityExpiryDate: json['commodity_expiry_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isSave: json['is_save'] ?? false,
      isSubmit: json['is_submit'] ?? false,
      commodity: AssignedCommodityDetail.fromJson(json['commodity']),
    );
  }
}
class AssignedCommodityDetail {
  final int id;
  final String name;
  final int categoryId;
  final int brandId;
  final int uomId;
  final String unitValue;
  final String image;
  final String status;
  final String createdAt;
  final String updatedAt;
  final AssignedBrand brand;
  final AssignedUOM uom;

  AssignedCommodityDetail({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.brandId,
    required this.uomId,
    required this.unitValue,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.brand,
    required this.uom,
  });

  factory AssignedCommodityDetail.fromJson(Map<String, dynamic> json) {
    return AssignedCommodityDetail(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'],
      brandId: json['brand_id'],
      uomId: json['uom_id'],
      unitValue: json['unit_value'],
      image: json['image'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      brand: AssignedBrand.fromJson(json['brand']),
      uom: AssignedUOM.fromJson(json['uom']),
    );
  }
}
class AssignedBrand {
  final int id;
  final String name;
  final String status;
  final String createdAt;
  final String updatedAt;

  AssignedBrand({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignedBrand.fromJson(Map<String, dynamic> json) {
    return AssignedBrand(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
class AssignedUOM {
  final int id;
  final String name;
  final String status;
  final String createdAt;
  final String updatedAt;

  AssignedUOM({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignedUOM.fromJson(Map<String, dynamic> json) {
    return AssignedUOM(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
