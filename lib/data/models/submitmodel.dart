class SubmitCommodity {
  final int commodityId;
  final int submittedSurveyId;
  final String? amount;
  final String? availability;
  final String? expiryDate;
  final int? brandId;
  final int? unitId;

  SubmitCommodity({
    required this.commodityId,
    required this.submittedSurveyId,
    this.amount,
    this.availability,
    this.expiryDate,
    this.brandId,
    this.unitId,
  });
}
