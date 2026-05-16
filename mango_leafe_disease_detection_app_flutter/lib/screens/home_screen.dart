import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import '../utils/disease_info.dart';
import 'processing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      await Permission.storage.request();
    }
    
    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessingScreen(imageFile: File(file.path)),
        ),
      );
    }
  }

  void _showPickerOptions(BuildContext context, Map<String, String> t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadius)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(t['capture_leaf']!),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(t['gallery']!),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final lang = provider.currentLanguage;
    final t = translations[lang]!;
    final recentHistory = provider.historyList.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t['app_name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => provider.toggleLanguage(),
            child: Text(
              lang == 'EN' ? 'বাং' : 'EN',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start New Analysis Card
            GestureDetector(
              onTap: () => _showPickerOptions(context, t),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.document_scanner, size: 64, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      "${t['app_name']} Analysis",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t['center_leaf']!,
                      style: const TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Recent History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t['history']!,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentHistory.isEmpty)
              const Text("No scans yet.", style: TextStyle(color: AppColors.textSecondary))
            else
              ...recentHistory.map((item) => _HomeExpandableHistoryCard(history: item, translations: t)),

            const SizedBox(height: 32),
            
            // Quick Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(30),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: AppColors.secondary),
                      SizedBox(width: 8),
                      Text("Quick Tip", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t['warning']!,
                    style: const TextStyle(color: AppColors.textPrimary),
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

/// Compact expandable history card for the Home dashboard.
/// Shows image + confidence badge + treatment summary on tap.
class _HomeExpandableHistoryCard extends StatefulWidget {
  final dynamic history;
  final Map<String, String> translations;

  const _HomeExpandableHistoryCard({
    required this.history,
    required this.translations,
  });

  @override
  State<_HomeExpandableHistoryCard> createState() => _HomeExpandableHistoryCardState();
}

class _HomeExpandableHistoryCardState extends State<_HomeExpandableHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final history = widget.history;
    final t = widget.translations;
    final dateStr = '${history.timestamp.day}/${history.timestamp.month}/${history.timestamp.year}';
    final imageFile = File(history.imagePath);
    final imageExists = imageFile.existsSync();
    final info = diseaseInfo[history.diseaseName];
    final isHealthy = history.diseaseName == 'Healthy';
    final confidencePercent = (history.confidence * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(
          color: _isExpanded ? AppColors.primary : Colors.grey.shade300,
          width: _isExpanded ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageExists
                        ? Image.file(imageFile, width: 44, height: 44, fit: BoxFit.cover)
                        : Container(
                            width: 44, height: 44,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(history.diseaseName, style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHealthy ? AppColors.primary : Colors.red.shade700,
                        )),
                        const SizedBox(height: 2),
                        Text('$confidencePercent%  •  $dateStr',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Expanded content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  if (imageExists)
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: Image.file(imageFile, fit: BoxFit.cover),
                    ),
                  if (info != null && !isHealthy)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (info.organicSolutions.isNotEmpty) ...[                            Text('🌱 ${t['organic_solutions'] ?? 'Organic Solutions'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ...info.organicSolutions.map<Widget>((s) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Text('• $s', style: const TextStyle(fontSize: 12)),
                            )),
                          ],
                          if (info.preventionTips.isNotEmpty) ...[                            const SizedBox(height: 8),
                            Text('🛡️ ${t['prevention_tips'] ?? 'Prevention'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ...info.preventionTips.map<Widget>((s) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Text('• $s', style: const TextStyle(fontSize: 12)),
                            )),
                          ],
                        ],
                      ),
                    ),
                  if (isHealthy && info != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('🌿 ${info.preventionTips.isNotEmpty ? info.preventionTips.first : 'Healthy!'}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 13)),
                    ),
                ],
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
