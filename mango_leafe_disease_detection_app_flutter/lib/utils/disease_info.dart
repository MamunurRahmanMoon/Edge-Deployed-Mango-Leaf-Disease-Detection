import '../models/treatment_plan.dart';

final Map<String, TreatmentPlan> diseaseInfo = {
  'Anthracnose': TreatmentPlan(
    diseaseName: 'Anthracnose',
    organicSolutions: ['Prune and destroy infected plant parts.', 'Apply a copper-based fungicide.'],
    chemicalTreatments: ['Chlorothalonil', 'Mancozeb'],
    preventionTips: ['Ensure proper spacing for air circulation.', 'Avoid overhead watering.'],
  ),
  'Bacterial Canker': TreatmentPlan(
    diseaseName: 'Bacterial Canker',
    organicSolutions: ['Remove and burn infected twigs and leaves.', 'Apply copper bactericides.'],
    chemicalTreatments: ['Streptomycin (if permitted)'],
    preventionTips: ['Use disease-free planting material.', 'Sterilize pruning tools.'],
  ),
  'Cutting Weevil': TreatmentPlan(
    diseaseName: 'Cutting Weevil', 
    organicSolutions: ['Manually remove adults.'], 
    chemicalTreatments: ['Insecticides like Imidacloprid'], 
    preventionTips: ['Maintain orchard hygiene.']
  ),
  'Die Back': TreatmentPlan(
    diseaseName: 'Die Back', 
    organicSolutions: ['Prune dead branches below the infected area.'], 
    chemicalTreatments: ['Copper oxychloride'], 
    preventionTips: ['Avoid water stress.']
  ),
  'Gall Midge': TreatmentPlan(
    diseaseName: 'Gall Midge', 
    organicSolutions: ['Remove young infected leaves.'], 
    chemicalTreatments: ['Dimethoate'], 
    preventionTips: ['Plough soil to expose pupae.']
  ),
  'Healthy': TreatmentPlan(
    diseaseName: 'Healthy', 
    organicSolutions: [], 
    chemicalTreatments: [], 
    preventionTips: ['Continue good farming practices!']
  ),
  'Powdery Mildew': TreatmentPlan(
    diseaseName: 'Powdery Mildew', 
    organicSolutions: ['Apply sulfur or neem oil.'], 
    chemicalTreatments: ['Hexaconazole'], 
    preventionTips: ['Avoid excess nitrogen fertilizer.']
  ),
  'Sooty Mould': TreatmentPlan(
    diseaseName: 'Sooty Mould', 
    organicSolutions: ['Wash leaves with soapy water.'], 
    chemicalTreatments: ['Control insects producing honeydew (like aphids) with appropriate insecticides.'], 
    preventionTips: ['Control sap-sucking insects.']
  ),
};
