import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../models/scan_history.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import '../utils/disease_info.dart';
import '../widgets/disease_badge.dart';

class ResultsScreen extends StatefulWidget {
  final File imageFile;
  final String diseaseName;
  final double confidence;

  const ResultsScreen({
    super.key,
    required this.imageFile,
    required this.diseaseName,
    required this.confidence,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isSaved = false;

  void _saveToHistory(BuildContext context) {
    if (_isSaved) return;

    final provider = Provider.of<AppProvider>(context, listen: false);
    final history = ScanHistory(
      imagePath: widget.imageFile.path,
      diseaseName: widget.diseaseName,
      confidence: widget.confidence,
      timestamp: DateTime.now(),
    );
    provider.addHistory(history);
    
    setState(() {
      _isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to History')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppProvider>(context).currentLanguage;
    final t = translations[lang]!;
    final info = diseaseInfo[widget.diseaseName] ?? diseaseInfo['Healthy']!;

    Widget buildSpacedCard(Widget child) {
      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: child,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t['app_name'] ?? 'MangoCare', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.check : Icons.save),
            onPressed: () => _saveToHistory(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 250,
              child: Image.file(widget.imageFile, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                children: [
                  DiseaseBadge(diseaseName: widget.diseaseName, confidence: widget.confidence),
                  const SizedBox(height: 24),
                  
                  if (info.organicSolutions.isNotEmpty)
                    buildSpacedCard(
                      ExpansionTile(
                        leading: const Text('🌱', style: TextStyle(fontSize: 24)),
                        title: Text(t['organic_solutions'] ?? 'Organic Solutions', style: const TextStyle(fontWeight: FontWeight.bold)),
                        children: info.organicSolutions.map((sol) => ListTile(title: Text('• $sol'))).toList(),
                      )
                    ),
                  
                  if (info.chemicalTreatments.isNotEmpty)
                     buildSpacedCard(
                      ExpansionTile(
                        leading: const Text('🧪', style: TextStyle(fontSize: 24)),
                        title: Text(t['chemical_treatments'] ?? 'Chemical Treatments', style: const TextStyle(fontWeight: FontWeight.bold)),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withAlpha(25),
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(t['warning'] ?? 'Use chemicals responsibly.', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                          ),
                          ...info.chemicalTreatments.map((sol) => ListTile(title: Text('• $sol'))),
                        ],
                      )
                    ),
                  
                  if (info.preventionTips.isNotEmpty)
                     buildSpacedCard(
                      ExpansionTile(
                        leading: const Text('🛡️', style: TextStyle(fontSize: 24)),
                        title: Text(t['prevention_tips'] ?? 'Prevention Tips', style: const TextStyle(fontWeight: FontWeight.bold)),
                        children: info.preventionTips.map((tip) => ListTile(title: Text('• $tip'))).toList(),
                      )
                    ),
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaved ? Colors.grey : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius))
                      ),
                      onPressed: () => _saveToHistory(context),
                      icon: Icon(_isSaved ? Icons.check : Icons.bookmark, color: Colors.white),
                      label: Text(_isSaved ? 'Saved' : (t['save_history'] ?? 'Save to History'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
