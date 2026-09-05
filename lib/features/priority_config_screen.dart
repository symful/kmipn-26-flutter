import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/design_system/design_system.dart';
import '../../api/client.dart';

class PriorityConfigScreen extends ConsumerStatefulWidget {
  const PriorityConfigScreen({super.key});

  @override
  ConsumerState<PriorityConfigScreen> createState() =>
      _PriorityConfigScreenState();
}

class _PriorityConfigScreenState extends ConsumerState<PriorityConfigScreen> {
  PriorityConfig? _config;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final data = await client.getPriorityConfigs();
      setState(() {
        final pw = data['priority_weights'] as Map<String, dynamic>?;
        if (pw != null) {
          _config = PriorityConfig.fromJson(pw);
        } else {
          _config = null;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _saveWeights(Map<String, dynamic> weights) async {
    setState(() => _saving = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.savePriorityConfig(weights: weights);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.konfigurasiBobotTersimpan,
            ),
            backgroundColor: SigapColors.primary,
          ),
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.gagalMenyimpan(e.toString()),
            ),
            backgroundColor: SigapColors.perluTindakan,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeRole = ref.watch(authNotifierProvider).activeRole ?? '';
    return AuthenticatedShell(
      activeRole: activeRole,
      useScaffold: true,
      backgroundColor: SigapColors.bgScreen,
      appBar: SigapAppBar(
        title: AppLocalizations.of(context)!.bobotPrioritas,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: SigapColors.primary),
            )
          : _error != null
          ? Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: ErrorRetryView(message: _error!, onRetry: _load),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info banner
                  SigapCard(
                    borderTopColor: SigapColors.diproses,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.tune, color: SigapColors.diproses, size: 22),
                        SizedBox(width: SigapSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.algoritmaPenilaianPrioritas,
                                style: TextStyle(
                                  fontSize: SigapTypography.bodyText,
                                  fontWeight: FontWeight.bold,
                                  color: SigapColors.diproses,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.aturPersentaseBobot,
                                style: TextStyle(
                                  fontSize: SigapTypography.bodySmall,
                                  color: SigapColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                  if (_config != null)
                    _PriorityForm(
                      config: _config!,
                      saving: _saving,
                      onSave: _saveWeights,
                    )
                  else
                    _PriorityForm(
                      config: PriorityConfig(),
                      saving: _saving,
                      onSave: _saveWeights,
                    ),
                ],
              ),
            ),
    );
  }
}

class _PriorityForm extends StatefulWidget {
  final PriorityConfig config;
  final bool saving;
  final void Function(Map<String, dynamic>) onSave;
  const _PriorityForm({
    required this.config,
    required this.saving,
    required this.onSave,
  });

  @override
  State<_PriorityForm> createState() => _PriorityFormState();
}

class _PriorityFormState extends State<_PriorityForm> {
  late Map<String, double> _weights;

  Map<String, String> _factorLabels(AppLocalizations l10n) => {
    'severity': l10n.faktorKeparahan,
    'recency': l10n.faktorKebaruan,
    'category': l10n.faktorUrgensi,
    'location': l10n.faktorKepadatan,
    'history': l10n.faktorRiwayat,
  };

  final Map<String, IconData> _factorIcons = const {
    'severity': Icons.warning_amber_rounded,
    'recency': Icons.schedule,
    'category': Icons.category_outlined,
    'location': Icons.location_on_outlined,
    'history': Icons.history,
  };

  @override
  void initState() {
    super.initState();
    _weights = {};
    final saved = <String, double>{};
    final rules = widget.config.rules;
    if (rules != null) {
      for (final r in rules) {
        final factor = r['factor'] as String?;
        final weight = r['weight'];
        if (factor != null && weight != null) {
          saved[factor] = (weight is num) ? weight.toDouble() : 0.0;
        }
      }
    }
    final defaults = {
      'severity': 0.3,
      'recency': 0.2,
      'category': 0.2,
      'location': 0.15,
      'history': 0.15,
    };
    for (final key in defaults.keys) {
      _weights[key] = saved[key] ?? defaults[key]!;
    }
  }

  double get _totalPercentage {
    return _weights.values.fold(0.0, (sum, val) => sum + val);
  }

  @override
  Widget build(BuildContext context) {
    final total = (_totalPercentage * 100).round();
    final isExact100 = total == 100;
    final dl10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total percentage status card
          SigapCard(
            borderTopColor: isExact100
                ? SigapColors.selesai
                : SigapColors.warning,
            child: Row(
              children: [
                Icon(
                  isExact100 ? Icons.check_circle : Icons.info,
                  color: isExact100 ? SigapColors.selesai : SigapColors.warning,
                  size: 20,
                ),
                const SizedBox(width: SigapSpacing.sm),
                Expanded(
                  child: Text(
                    isExact100
                        ? dl10n.totalBobotSesuai
                        : dl10n.totalBobotDisarankan(total),
                    style: TextStyle(
                      fontSize: SigapTypography.bodySmall,
                      fontWeight: FontWeight.w600,
                      color: isExact100
                          ? SigapColors.selesai
                          : SigapColors.warningTextStrong,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.md),

          // Sliders card
          SigapCard(
            child: Column(
              children: _weights.entries.map((e) {
                final label =
                    _factorLabels(dl10n)[e.key] ?? e.key.toUpperCase();
                final icon = _factorIcons[e.key] ?? Icons.tune;
                return _WeightSlider(
                  label: label,
                  icon: icon,
                  value: e.value,
                  onChanged: (v) => setState(() => _weights[e.key] = v),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: SigapSpacing.xl),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SigapColors.primary,
              foregroundColor: SigapColors.surface,
              padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SigapRadius.md),
              ),
            ),
            onPressed: widget.saving
                ? null
                : () => widget.onSave({'weights': _weights}),
            child: widget.saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SigapColors.surface,
                    ),
                  )
                : Text(
                    dl10n.simpanKonfigurasi,
                    style: const TextStyle(
                      fontSize: SigapTypography.bodyMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _WeightSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final ValueChanged<double> onChanged;

  const _WeightSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    final color = pct >= 25
        ? SigapColors.primary
        : pct >= 15
        ? SigapColors.diproses
        : SigapColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: SigapColors.primary),
              const SizedBox(width: SigapSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyText,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
              ),
              StatusPill(
                label: '$pct%',
                tone: color == SigapColors.primary
                    ? StatusTone.success
                    : color == SigapColors.diproses
                    ? StatusTone.warning
                    : StatusTone.neutral,
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: SigapColors.primary,
              inactiveTrackColor: SigapColors.border,
              thumbColor: SigapColors.primary,
              overlayColor: SigapColors.primary.withValues(alpha: 0.12),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 1,
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
