class TreatmentPlan {
  final String diseaseName;
  final List<String> organicSolutions;
  final List<String> chemicalTreatments;
  final List<String> preventionTips;

  TreatmentPlan({
    required this.diseaseName,
    required this.organicSolutions,
    required this.chemicalTreatments,
    required this.preventionTips,
  });
}
