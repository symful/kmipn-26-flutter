import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../api/types.g.dart';

class AdminDaerahPriorityConfigScreen extends ConsumerStatefulWidget {
  const AdminDaerahPriorityConfigScreen({super.key});

  @override
  ConsumerState<AdminDaerahPriorityConfigScreen> createState() =>
      _AdminDaerahPriorityConfigScreenState();
}

class _AdminDaerahPriorityConfigScreenState
    extends ConsumerState<AdminDaerahPriorityConfigScreen> {
  PriorityConfig? _config;
  bool _loading = true;
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
        // Extract the first (most recent) priority config entry from the paginated response
        _config = data.entries.isNotEmpty ? data.entries.first : null;
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
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.savePriorityConfig(weights: weights);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Konfigurasi disimpan')));
      }
      _load();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfigurasi Prioritas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: SigapColors.perluTindakan,
                  ),
                  Text('Gagal: $_error'),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(SigapSpacing.md),
                    decoration: BoxDecoration(
                      color: SigapColors.diproses.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                      border: Border.all(
                        color: SigapColors.diproses.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: SigapColors.diproses,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Atur bobot faktor yang mempengaruhi skor prioritas laporan.',
                            style: TextStyle(
                              fontSize: 12,
                              color: SigapColors.diproses,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                  if (_config != null)
                    _PriorityForm(config: _config!, onSave: _saveWeights),
                ],
              ),
            ),
    );
  }
}

class _PriorityForm extends StatefulWidget {
  final PriorityConfig config;
  final void Function(Map<String, dynamic>) onSave;
  const _PriorityForm({required this.config, required this.onSave});

  @override
  State<_PriorityForm> createState() => _PriorityFormState();
}

class _PriorityFormState extends State<_PriorityForm> {
  late Map<String, double> _weights;

  @override
  void initState() {
    super.initState();
    _weights = {};
    // Convert rules list to weights map: each rule has 'factor'/'weight' keys
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._weights.entries.map(
          (e) => _WeightSlider(
            label: e.key,
            value: e.value,
            onChanged: (v) => setState(() => _weights[e.key] = v),
          ),
        ),
        const SizedBox(height: SigapSpacing.xl),
        ElevatedButton(
          onPressed: () => widget.onSave({'weights': _weights}),
          child: const Text(Strings.simpanKonfigurasi),
        ),
      ],
    );
  }
}

class _WeightSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _WeightSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.replaceFirst(label[0], label[0].toUpperCase()),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: value >= 0.25
                      ? Colors.green
                      : value >= 0.1
                      ? Colors.orange
                      : SigapColors.perluTindakan,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 20,
            label: '${(value * 100).round()}%',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
