import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/analytics_models.dart';
import '../services/database_service.dart';
import '../services/risk_prediction_service.dart';
import '../widgets/risk_indicator_widget.dart';

class RiskDetailsScreen extends StatefulWidget {
  const RiskDetailsScreen({Key? key}) : super(key: key);

  @override
  State<RiskDetailsScreen> createState() => _RiskDetailsScreenState();
}

class _RiskDetailsScreenState extends State<RiskDetailsScreen> {
  final _dbService = DatabaseService();
  RiskAssessment? _risk;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateRisk();
  }

  Future<void> _calculateRisk() async {
    setState(() => _isLoading = true);

    try {
      final symptoms = await _dbService.getAllSymptomLogs();
      final risk = await RiskPredictionService.calculateRealTimeRisk(symptoms);

      if (mounted) {
        setState(() {
          _risk = risk;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔴 [RISK DETAILS] Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Risk Analizi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _calculateRisk,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _risk == null
          ? const Center(child: Text('Risk hesaplanamadı'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RiskIndicatorWidget(risk: _risk!),
                  const SizedBox(height: 24),
                  _buildRiskExplanation(),
                  const SizedBox(height: 24),
                  _buildRecommendations(),
                ],
              ),
            ),
    );
  }

  Widget _buildRiskExplanation() {
    final color = RiskPredictionService.getRiskColor(_risk!.riskLevel);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Risk Açıklaması',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              RiskPredictionService.getRiskDescription(_risk!.riskLevel),
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _risk!.riskScore / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              'Risk Puanı: ${_risk!.riskScore.toStringAsFixed(1)}/100',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final riskLevel = _risk!.riskLevel;
    late List<String> recommendations;

    if (riskLevel == 'DÜŞÜK') {
      recommendations = [
        'Sık olarak su içmeyi unutmayın',
        'Hava kalitesini takip etmeye devam edin',
        'İyi bir uyku düzenini koruyun',
      ];
    } else if (riskLevel == 'ORTA') {
      recommendations = [
        'İlaçlarınızı erişebileceğiniz yerde bulundurun',
        'Riskin yükselmesi durumunda doktor ile iletişim kurmayı düşünün',
        'Tetikleyicilerden kaçınmaya çalışın',
      ];
    } else if (riskLevel == 'YÜKSEK') {
      recommendations = [
        '⚠️ İlaçlarınızı hemen yanınızda bulundurun',
        '⚠️ Riskliyok alanlardanuzak durmaya çalışın',
        '⚠️ Acil durum numarasını elinizin altında tutun',
      ];
    } else {
      recommendations = [
        '🚨 ACİL TIP HİZMETLERİNİ ARAYIN',
        '🚨 İlaçlarınızı hemen kullanın',
        '🚨 Güvenli bir ortamda olduğunuzdan emin olun',
      ];
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Öneriler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...recommendations
                .map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            rec,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}
