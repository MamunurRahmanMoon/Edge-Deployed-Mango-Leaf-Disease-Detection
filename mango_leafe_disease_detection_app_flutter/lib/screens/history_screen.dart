import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../utils/translations.dart';
import '../utils/constants.dart';
import '../utils/disease_info.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final lang = provider.currentLanguage;
    final t = translations[lang]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t['history']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: provider.historyList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No scan history yet.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.padding),
              itemCount: provider.historyList.length,
              itemBuilder: (context, index) {
                final history = provider.historyList[index];
                final dateStr =
                    '${history.timestamp.day}/${history.timestamp.month}/${history.timestamp.year}';
                final timeStr =
                    '${history.timestamp.hour.toString().padLeft(2, '0')}:${history.timestamp.minute.toString().padLeft(2, '0')}';
                final imageFile = File(history.imagePath);
                final imageExists = imageFile.existsSync();
                final isHealthy = history.diseaseName == 'Healthy';
                final confidencePercent =
                    (history.confidence * 100).toStringAsFixed(1);

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryDetailScreen(
                            imagePath: history.imagePath,
                            diseaseName: history.diseaseName,
                            confidence: history.confidence,
                            timestamp: history.timestamp,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageExists
                                ? Image.file(imageFile,
                                    width: 56, height: 56, fit: BoxFit.cover)
                                : Container(
                                    width: 56,
                                    height: 56,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported,
                                        color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  history.diseaseName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isHealthy
                                        ? AppColors.primary
                                        : Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$confidencePercent% confidence',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$dateStr  •  $timeStr',
                                  style: TextStyle(
                                      color: Colors.grey.shade400, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Full-screen detail view for a history record.
/// Shows the scanned image prominently and all treatment information,
/// mirroring the Results screen layout.
class HistoryDetailScreen extends StatelessWidget {
  final String imagePath;
  final String diseaseName;
  final double confidence;
  final DateTime timestamp;

  const HistoryDetailScreen({
    super.key,
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppProvider>(context).currentLanguage;
    final t = translations[lang]!;
    final imageFile = File(imagePath);
    final imageExists = imageFile.existsSync();
    final info = diseaseInfo[diseaseName] ?? diseaseInfo['Healthy']!;
    final isHealthy = diseaseName == 'Healthy';
    final confidencePercent = (confidence * 100).toStringAsFixed(1);
    final dateStr =
        '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

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
        title: Text(t['history']!,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full image
            if (imageExists)
              SizedBox(
                height: 280,
                child: Image.file(imageFile, fit: BoxFit.cover),
              )
            else
              Container(
                height: 280,
                color: Colors.grey.shade200,
                child: const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 64, color: Colors.grey)),
              ),

            Padding(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease name + badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isHealthy
                              ? AppColors.primary.withAlpha(25)
                              : Colors.red.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isHealthy ? '✅ Healthy' : '⚠️ $diseaseName',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isHealthy
                                ? AppColors.primary
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$confidencePercent%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: isHealthy
                              ? AppColors.primary
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Scanned on $dateStr at $timeStr',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),

                  const SizedBox(height: 24),

                  // Treatment cards (only for diseases)
                  if (!isHealthy) ...[
                    if (info.organicSolutions.isNotEmpty)
                      buildSpacedCard(
                        ExpansionTile(
                          leading: const Text('🌱', style: TextStyle(fontSize: 24)),
                          title: Text(t['organic_solutions'] ?? 'Organic Solutions', style: const TextStyle(fontWeight: FontWeight.bold)),
                          children: info.organicSolutions.map((sol) => ListTile(title: Text('• $sol'))).toList(),
                        ),
                      ),
                    if (info.chemicalTreatments.isNotEmpty) ...[
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
                        ),
                      ),
                    ],
                    if (info.preventionTips.isNotEmpty)
                      buildSpacedCard(
                        ExpansionTile(
                          leading: const Text('🛡️', style: TextStyle(fontSize: 24)),
                          title: Text(t['prevention_tips'] ?? 'Prevention Tips', style: const TextStyle(fontWeight: FontWeight.bold)),
                          children: info.preventionTips.map((tip) => ListTile(title: Text('• $tip'))).toList(),
                        ),
                      ),
                  ],

                  // Healthy message
                  if (isHealthy)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(
                            color: AppColors.primary.withAlpha(50)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 48),
                          const SizedBox(height: 12),
                          const Text('Your mango leaf looks healthy!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primary)),
                          if (info.preventionTips.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(info.preventionTips.first,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
