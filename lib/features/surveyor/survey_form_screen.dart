import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SurveyFormScreen extends StatefulWidget {
  final String taskId;
  const SurveyFormScreen({super.key, required this.taskId});

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  String _kondisi = 'ringan';
  String _rekomendasi = 'approve';
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FORM SURVEI',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF9800).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.offline_pin,
                        size: 12,
                        color: Color(0xFFFF9800),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'offline',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Tersimpan 14:32',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                ),
                SizedBox(width: 8),
                Text(
                  '66%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: 0.66,
            backgroundColor: Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation(Color(0xFF00897B)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto grid
                  Text(
                    'Foto Bukti (3 sudut)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _PhotoSlot(label: 'Depan', icon: Icons.camera_alt),
                      SizedBox(width: 8),
                      _PhotoSlot(label: 'Samping', icon: Icons.camera_alt),
                      SizedBox(width: 8),
                      _PhotoSlot(label: 'Belakang', icon: Icons.camera_alt),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Kondisi picker
                  Text(
                    'Kondisi Kerusakan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _ConditionChip(
                        label: 'Ringan',
                        color: Color(0xFF4CAF50),
                        isSelected: _kondisi == 'ringan',
                        onTap: () => setState(() => _kondisi = 'ringan'),
                      ),
                      SizedBox(width: 8),
                      _ConditionChip(
                        label: 'Berat',
                        color: Color(0xFFFF9800),
                        isSelected: _kondisi == 'berat',
                        onTap: () => setState(() => _kondisi = 'berat'),
                      ),
                      SizedBox(width: 8),
                      _ConditionChip(
                        label: 'Kritis',
                        color: Color(0xFFF44336),
                        isSelected: _kondisi == 'kritis',
                        onTap: () => setState(() => _kondisi = 'kritis'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // GPS card
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF00897B),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lokasi GPS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '-6.9175, 107.6195',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Catatan textarea
                  Text(
                    'Catatan Lapangan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _catatanController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan survei...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Rekomendasi radio
                  Text(
                    'Rekomendasi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  RadioGroup<String>(
                    groupValue: _rekomendasi,
                    onChanged: (val) =>
                        setState(() => _rekomendasi = val ?? _rekomendasi),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'approve',
                          title: Text('Approve - Laporan valid'),
                          dense: true,
                        ),
                        RadioListTile<String>(
                          value: 'reject',
                          title: Text('Reject - Laporan tidak valid'),
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky footer
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/surveyor/review/${widget.taskId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00897B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Lanjut ke review hasil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String label;
  final IconData icon;
  const _PhotoSlot({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Color(0xFFE0E0E0),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFFBDBDBD)),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _ConditionChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
