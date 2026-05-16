import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Service responsible for loading the Float16 quantized TFLite model
/// and running client-side normalized inference on mango leaf images.
///
/// CRITICAL: The exported model has NO embedded Keras preprocessing layers.
/// All resizing and pixel normalization (/ 255.0) MUST happen here in Dart.
class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  // Updated to match the actual Float16 quantized model filename on disk
  final String _modelPath = 'assets/models/mangocare_model_float16.tflite';
  final String _labelPath = 'assets/models/labels.txt';

  // Model input dimensions (must match the stripped model's input tensor)
  static const int _inputSize = 256;

  Future<void> init() async {
    await _loadLabels();
    await _loadModel();
  }

  /// Loads class labels from labels.txt so they stay in sync with training.
  Future<void> _loadLabels() async {
    try {
      final raw = await rootBundle.loadString(_labelPath);
      _labels = raw
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      debugPrint('Loaded ${_labels.length} labels: $_labels');
    } catch (e) {
      debugPrint('Error loading labels: $e');
      // Fallback to hardcoded labels if file read fails
      _labels = [
        'Anthracnose',
        'Bacterial Canker',
        'Cutting Weevil',
        'Die Back',
        'Gall Midge',
        'Healthy',
        'Powdery Mildew',
        'Sooty Mould',
      ];
    }
  }

  /// Loads the TFLite model with optional GPU/NNAPI hardware acceleration.
  /// Falls back to CPU if delegate initialization fails.
  Future<void> _loadModel() async {
    // Strategy: Try GPU-accelerated interpreter first.
    // If interpreter creation fails (common on emulators with SwiftShader),
    // fall back to CPU-only interpreter.

    // --- Attempt 1: GPU-accelerated ---
    if (Platform.isAndroid) {
      try {
        final gpuOptions = InterpreterOptions()..addDelegate(GpuDelegateV2());
        _interpreter = await Interpreter.fromAsset(_modelPath, options: gpuOptions);
        debugPrint('Model loaded with GPU delegate');
        return; // Success — done
      } catch (e) {
        debugPrint('GPU-accelerated interpreter failed: $e');
        debugPrint('Falling back to CPU...');
      }
    } else if (Platform.isIOS) {
      try {
        final gpuOptions = InterpreterOptions()..addDelegate(GpuDelegate());
        _interpreter = await Interpreter.fromAsset(_modelPath, options: gpuOptions);
        debugPrint('Model loaded with iOS Metal delegate');
        return;
      } catch (e) {
        debugPrint('iOS GPU interpreter failed, falling back to CPU: $e');
      }
    }

    // --- Attempt 2: CPU-only fallback ---
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath, options: InterpreterOptions());
      debugPrint('Model loaded on CPU (no delegate)');
    } catch (e) {
      debugPrint('CPU interpreter also failed: $e');
      throw Exception('Failed to load TFLite model: $e');
    }
  }

  /// Runs inference on a leaf image file.
  ///
  /// Pipeline:
  ///   1. Decode & resize to 256×256
  ///   2. Build Float32 tensor [1, 256, 256, 3]
  ///   3. Normalize every pixel channel by dividing by 255.0
  ///   4. Run interpreter
  ///   5. Return top predicted label and confidence
  Future<Map<String, dynamic>> runInference(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('Interpreter is not initialized. Call init() first.');
    }

    // Decode the raw image bytes
    final rawImage = await imageFile.readAsBytes();
    final image = img.decodeImage(rawImage);
    if (image == null) throw Exception('Failed to decode image');

    // Step 1: Resize to model's expected input dimensions (256×256)
    final resizedImage = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
    );

    // Step 2 & 3: Build the input tensor [1, 256, 256, 3] with normalization.
    //
    // CRITICAL MATH: Every raw pixel value [0–255] is divided by 255.0
    // to produce values in the [0.0, 1.0] range. The Float16 quantized model
    // was trained on normalized data and contains NO internal Rescaling layer.
    // Feeding raw [0–255] values WILL produce garbage results or crash on GPU.
    var input = List.generate(
      1,
      (batch) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0, // Red channel normalized
              pixel.g / 255.0, // Green channel normalized
              pixel.b / 255.0, // Blue channel normalized
            ];
          },
        ),
      ),
    );

    // Step 4: Prepare output tensor [1, numClasses] and run inference
    var output = List.filled(1, List.filled(_labels.length, 0.0));
    _interpreter!.run(input, output);

    final results = output[0];

    // Step 5: Find the class with the highest probability
    double maxConfidence = -1.0;
    int maxIndex = 0;
    for (int i = 0; i < results.length; i++) {
      if (results[i] > maxConfidence) {
        maxConfidence = results[i];
        maxIndex = i;
      }
    }

    debugPrint('Inference result: ${_labels[maxIndex]} (${(maxConfidence * 100).toStringAsFixed(1)}%)');

    return {
      'label': _labels[maxIndex],
      'confidence': maxConfidence,
    };
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
