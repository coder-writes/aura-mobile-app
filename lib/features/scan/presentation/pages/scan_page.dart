import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/scan_remote_datasource.dart';

enum ScanMode { tb, eye }

class ScanPage extends StatefulWidget {
  const ScanPage({
    super.key,
    this.initialMode = ScanMode.tb,
    this.lockMode = false,
  });

  final ScanMode initialMode;
  final bool lockMode;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ScanRemoteDataSource _dataSource = ScanRemoteDataSource();
  final ImagePicker _picker = ImagePicker();

  late ScanMode _mode;
  bool _isLoading = false;
  String? _selectedImagePath;

  Map<String, dynamic>? _tbResult;
  Map<String, dynamic>? _eyeResult;

  String? _tbError;
  String? _eyeError;

  String _filename(String path) => path.split(RegExp(r'[\\/]')).last;

  bool get _isTbMode => _mode == ScanMode.tb;

  String get _activeTitle => _isTbMode ? 'TB Scan' : 'Eye Scan';

  String get _activeEndpoint =>
      _isTbMode ? '/predict/tb' : '/predict/eye-disease';

  String get _activeImageGuide => _isTbMode
      ? 'Upload a clear chest X-ray image (PA/AP view), with both lungs visible and minimal blur.'
      : 'Upload a clear retinal fundus image centered on the retina, with good lighting and no heavy glare.';

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted || file == null) return;

    setState(() {
      _selectedImagePath = file.path;
      if (_isTbMode) {
        _tbError = null;
      } else {
        _eyeError = null;
      }
    });
  }

  void _switchMode(ScanMode mode) {
    if (widget.lockMode) return;
    if (_mode == mode) return;

    setState(() {
      _mode = mode;

      // Keep each mode isolated so users never see cross-mode state.
      if (_isTbMode) {
        _eyeError = null;
        _eyeResult = null;
      } else {
        _tbError = null;
        _tbResult = null;
      }
    });
  }

  Future<void> _runActiveScan() async {
    if (_isLoading) return;

    if (_selectedImagePath == null || _selectedImagePath!.trim().isEmpty) {
      setState(() {
        if (_isTbMode) {
          _tbError =
              'No image selected. Please pick a chest image before starting TB scan.';
        } else {
          _eyeError =
              'No image selected. Please pick an eye image before starting eye scan.';
        }
      });
      return;
    }

    setState(() {
      _isLoading = true;
      if (_isTbMode) {
        _tbError = null;
        _tbResult = null;
      } else {
        _eyeError = null;
        _eyeResult = null;
      }
    });

    try {
      if (_isTbMode) {
        final result = await _dataSource.runTbScan(
          imagePath: _selectedImagePath!,
        );
        if (!mounted) return;
        setState(() {
          _tbResult = result;
        });
      } else {
        final result = await _dataSource.runEyeScan(
          imagePath: _selectedImagePath!,
        );
        if (!mounted) return;
        setState(() {
          if (_isInvalidEyeImageResult(result)) {
            _eyeResult = null;
            _eyeError =
                'Invalid image. Please upload a clear retinal eye image only.';
          } else {
            _eyeResult = result;
          }
        });
      }
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      setState(() {
        if (_isTbMode) {
          _tbError = message;
        } else {
          _eyeError = _isInvalidEyeImageError(message)
              ? 'Invalid image. Please upload a clear retinal eye image only.'
              : message;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isInvalidEyeImageError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('invalid image') ||
        lower.contains('not an eye') ||
        lower.contains('not eye') ||
        lower.contains('retina not found') ||
        lower.contains('fundus not found') ||
        lower.contains('non-retinal') ||
        lower.contains('not a retinal') ||
        lower.contains('eye not detected') ||
        lower.contains('unable to detect eye');
  }

  bool _isInvalidEyeImageResult(Map<String, dynamic> result) {
    final raw = result.toString().toLowerCase();

    final explicitlyInvalid =
        result['isEye'] == false ||
        result['eyeDetected'] == false ||
        result['validImage'] == false ||
        result['invalidImage'] == true;

    if (explicitlyInvalid) return true;

    return raw.contains('invalid image') ||
        raw.contains('not an eye') ||
        raw.contains('not eye') ||
        raw.contains('retina not found') ||
        raw.contains('fundus not found') ||
        raw.contains('non-retinal') ||
        raw.contains('not a retinal') ||
        raw.contains('eye not detected') ||
        raw.contains('unable to detect eye');
  }

  void _clearImageAndState() {
    setState(() {
      _selectedImagePath = null;
      if (_isTbMode) {
        _tbError = null;
        _tbResult = null;
      } else {
        _eyeError = null;
        _eyeResult = null;
      }
    });
  }

  String _buildResultExplanation(Map<String, dynamic> result) {
    // Extract risk assessment
    final risk = result['risk']?.toString() ?? 'Unknown Risk';

    // Extract task type
    final task = result['task']?.toString() ?? (_isTbMode ? 'tb' : 'eye');

    final modeName = _isTbMode ? 'TB Screening' : 'Eye Scan';

    // Build risk-aware description and next steps
    String description = '';
    String nextSteps = '';

    if (task.toLowerCase().contains('tb')) {
      if (risk.toLowerCase().contains('high')) {
        description =
            'This chest X-ray analysis indicates signs consistent with tuberculosis. '
            'This is an AI-assisted screening result and requires clinical confirmation.';
        nextSteps =
            'This is a potential finding that requires urgent confirmation:\n'
            '• Consult a respiratory specialist or pulmonologist immediately\n'
            '• Get confirmatory tests: sputum smear microscopy, TB culture, or GeneXpert MTB/RIF\n'
            '• Do not delay - early diagnosis and treatment are critical';
      } else if (risk.toLowerCase().contains('low')) {
        description =
            'This chest X-ray analysis shows no obvious signs of tuberculosis. '
            'However, this is an AI-assisted screening result only.';
        nextSteps =
            'No immediate action required based on this screening:\n'
            '• Normal X-ray findings detected\n'
            '• If you have TB symptoms, consult a doctor for further evaluation\n'
            '• Regular screening recommended if at risk';
      } else {
        description =
            'The analysis result was generated. Please review the finding below.';
        nextSteps =
            'Next step: Consult with a healthcare provider to interpret the result '
            'in the context of clinical symptoms and risk factors.';
      }
    } else {
      if (risk.toLowerCase().contains('high') ||
          risk.toLowerCase().contains('positive')) {
        description =
            'This retinal image analysis indicates potential eye abnormality. '
            'This is an AI-assisted screening result requiring professional evaluation.';
        nextSteps =
            'This may indicate a potential eye condition:\n'
            '• Schedule an urgent appointment with an ophthalmologist\n'
            '• Bring this screening result to your consultation\n'
            '• Do not delay if experiencing vision changes or eye discomfort';
      } else if (risk.toLowerCase().contains('low') ||
          risk.toLowerCase().contains('negative')) {
        description =
            'This retinal image analysis appears normal based on AI evaluation. '
            'However, this is an AI-assisted screening result only.';
        nextSteps =
            'No immediate concerns detected:\n'
            '• Screening appears normal\n'
            '• Continue routine eye care and regular check-ups\n'
            '• Contact an ophthalmologist if you experience vision changes';
      } else {
        description =
            'The analysis result was generated. Please review the finding below.';
        nextSteps =
            'Next step: Consult with an eye care professional to interpret the result.';
      }
    }

    final lines = <String>[
      '✓ $modeName completed',
      '',
      'Scan Result: $risk',
      '',
      description,
      '',
      'Recommended Actions:',
      nextSteps,
    ];

    return lines.join('\n');
  }

  String _buildErrorExplanation(String error) {
    final lower = error.toLowerCase();
    final modeName = _isTbMode ? 'TB' : 'Eye';

    if (lower.contains('field required') || lower.contains('422')) {
      return [
        '$modeName scan request was received, but backend rejected the input format.',
        'Most likely reason: required multipart field file was missing or empty.',
        'What to check:',
        '- Select image again and retry.',
        '- Confirm backend expects form-data with key file.',
        '- Confirm file is a valid image type.',
        'Raw error: $error',
      ].join('\n');
    }

    if (lower.contains('timeout') || lower.contains('connection')) {
      return [
        '$modeName scan could not reach the server in time.',
        'This usually indicates ngrok tunnel/network delay or backend downtime.',
        'What to check:',
        '- Verify ngrok URL is active.',
        '- Verify backend on port 8000 is running.',
        '- Retry with stable internet.',
        'Raw error: $error',
      ].join('\n');
    }

    if (lower.contains('404')) {
      return [
        '$modeName endpoint path was not found on backend.',
        'Please verify endpoint path and route registration.',
        'Expected path: $_activeEndpoint',
        'Raw error: $error',
      ].join('\n');
    }

    return [
      '$modeName scan failed due to backend or request issue.',
      'Please retry once. If issue continues, verify backend logs for exact cause.',
      'Raw error: $error',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _selectedImagePath;
    final imageName = imagePath == null ? null : _filename(imagePath);

    final activeResult = _isTbMode ? _tbResult : _eyeResult;
    final activeError = _isTbMode ? _tbError : _eyeError;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Scan Center')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF7EE), Color(0xFFF7F2EA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoCard(baseUrl: AppEnv.scanApiBaseUrl),
                const SizedBox(height: 16),
                if (!widget.lockMode)
                  _ModeSwitch(mode: _mode, onModeChanged: _switchMode),
                if (!widget.lockMode) const SizedBox(height: 14),
                const SizedBox(height: 14),
                _UploadPanel(
                  title: _activeTitle,
                  guideText: _activeImageGuide,
                  imagePath: imagePath,
                  imageName: imageName,
                  onPick: _pickImage,
                  onClear: imagePath == null ? null : _clearImageAndState,
                ),
                const SizedBox(height: 14),
                _ActionPanel(
                  endpoint: _activeEndpoint,
                  modeTitle: _activeTitle,
                  isLoading: _isLoading,
                  onRun: _runActiveScan,
                ),
                const SizedBox(height: 16),
                _DetailedResultCard(
                  title: _activeTitle,
                  endpoint: _activeEndpoint,
                  isLoading: _isLoading,
                  result: activeResult,
                  error: activeError,
                  explanation: activeResult == null
                      ? (activeError == null
                            ? null
                            : _buildErrorExplanation(activeError))
                      : _buildResultExplanation(activeResult),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.baseUrl});

  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: AppColors.ghostBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connected Scan Backend',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            baseUrl,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onModeChanged});

  final ScanMode mode;
  final ValueChanged<ScanMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: AppColors.ghostBorder,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'TB Scan',
              icon: Icons.air_rounded,
              selected: mode == ScanMode.tb,
              onTap: () => onModeChanged(ScanMode.tb),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModeButton(
              label: 'Eye Scan',
              icon: Icons.visibility_rounded,
              selected: mode == ScanMode.eye,
              onTap: () => onModeChanged(ScanMode.eye),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF2EFEA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: selected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel({
    required this.title,
    required this.guideText,
    required this.imagePath,
    required this.imageName,
    required this.onPick,
    required this.onClear,
  });

  final String title;
  final String guideText;
  final String? imagePath;
  final String? imageName;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: AppColors.ghostBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title Input Image',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(guideText, style: AppTextStyles.bodySmall),
          const SizedBox(height: 6),
          Text(
            imageName == null ? 'No image selected' : 'Selected: $imageName',
            style: AppTextStyles.bodySmall.copyWith(
              color: imageName == null
                  ? AppColors.onSurfaceVariant
                  : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 190,
              color: const Color(0xFFF2EFEA),
              child: imagePath == null
                  ? Center(
                      child: Text(
                        'Preview appears here',
                        style: AppTextStyles.bodySmall,
                      ),
                    )
                  : Image.file(File(imagePath!), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: onPick,
                child: const Text('Pick Image'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.endpoint,
    required this.modeTitle,
    required this.isLoading,
    required this.onRun,
  });

  final String endpoint;
  final String modeTitle;
  final bool isLoading;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: AppColors.ghostBorder,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Endpoint',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(endpoint, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: isLoading ? null : onRun,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(isLoading ? 'Running...' : 'Run $modeTitle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedResultCard extends StatelessWidget {
  const _DetailedResultCard({
    required this.title,
    required this.endpoint,
    required this.isLoading,
    required this.result,
    required this.error,
    required this.explanation,
  });

  final String title;
  final String endpoint;
  final bool isLoading;
  final Map<String, dynamic>? result;
  final String? error;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: AppColors.ghostBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title Response',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            endpoint,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          if (explanation != null && explanation!.trim().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasError ? Colors.red.shade50 : const Color(0xFFF0F8F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasError
                      ? Colors.red.shade200
                      : AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                explanation!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: hasError ? Colors.red.shade900 : AppColors.onSurface,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else if (isLoading) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Analyzing your image... Please wait',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EFEA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Upload an image and tap "Run $title" to get scan results',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
