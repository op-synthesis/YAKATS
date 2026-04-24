import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/symptom_log.dart';
import '../models/analytics_models.dart';
import '../services/database_service.dart';
import '../services/analytics_service.dart';
import '../utils/app_theme.dart';
import '../utils/app_strings.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _dbService = DatabaseService();

  List<SymptomLog> _allSymptoms = [];
  TriggerAnalysis? _analysis;
  SymptomStatistics? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndAnalyze();
  }

  Future<void> _loadAndAnalyze() async {
    setState(() => _isLoading = true);

    try {
      print('🔵 [INSIGHTS] Loading symptoms...');
      final symptoms = await _dbService.getAllSymptomLogs();

      print('🔵 [INSIGHTS] Analyzing ${symptoms.length} symptoms...');
      final analysis = AnalyticsService.analyzeTriggers(symptoms);
      final stats = AnalyticsService.calculateStatistics(symptoms);

      if (mounted) {
        setState(() {
          _allSymptoms = symptoms;
          _analysis = analysis;
          _stats = stats;
          _isLoading = false;
        });
      }

      print('🟢 [INSIGHTS] Analysis complete!');
    } catch (e) {
      print('🔴 [INSIGHTS] Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI İçgörüleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAndAnalyze,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allSymptoms.isEmpty
          ? _buildEmptyState()
          : _buildInsightsContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz Yeterli Veri Yok',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI analizi için en az 3-5 semptom kaydı gerekiyor.\nSemptomlarınızı kaydetmeye başlayın!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsContent() {
    return RefreshIndicator(
      onRefresh: _loadAndAnalyze,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            _buildSummaryCard(),
            const SizedBox(height: 24),

            // Triggers section
            _buildSectionTitle('🎯 Tetikleyicileriniz'),
            const SizedBox(height: 12),
            _buildTriggersList(),
            const SizedBox(height: 24),

            // Statistics section
            _buildSectionTitle('📊 İstatistikler'),
            const SizedBox(height: 12),
            _buildStatisticsCards(),
            const SizedBox(height: 24),

            // Time patterns
            _buildSectionTitle('⏰ Zaman Desenleri'),
            const SizedBox(height: 12),
            _buildTimePatterns(),
            const SizedBox(height: 24),

            // Severity distribution
            _buildSectionTitle('📈 Şiddet Dağılımı'),
            const SizedBox(height: 12),
            _buildSeverityChart(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalSymptoms = _stats?.totalSymptoms ?? 0;
    final avgSeverity = _stats?.averageSeverity ?? 0;
    final topTriggers = _analysis?.triggers.take(3).toList() ?? [];

    return Card(
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Analiz Özeti',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Toplam Kayıt',
                    totalSymptoms.toString(),
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Ort. Şiddet',
                    avgSeverity.toStringAsFixed(1),
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Tetikleyici',
                    topTriggers.length.toString(),
                  ),
                ),
              ],
            ),
            if (topTriggers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🏆 En Güçlü Tetikleyici',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topTriggers.first.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      topTriggers.first.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTriggersList() {
    final triggers = _analysis?.triggers ?? [];

    if (triggers.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Henüz tetikleyici tespit edilemedi. Daha fazla veri gerekiyor.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Column(
      children: triggers.map((trigger) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getTriggerIcon(trigger.type),
                      color: _getTriggerColor(trigger.type),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trigger.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            trigger.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getTriggerColor(trigger.type).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(trigger.confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _getTriggerColor(trigger.type),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Confidence bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: trigger.confidence,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTriggerColor(trigger.type),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatisticsCards() {
    final mildCount = _stats?.mildCount ?? 0;
    final moderateCount = _stats?.moderateCount ?? 0;
    final severeCount = _stats?.severeCount ?? 0;
    final mostCommon = _stats?.mostCommonSymptom ?? 'N/A';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Hafif',
                mildCount.toString(),
                Colors.green,
                Icons.sentiment_satisfied,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Orta',
                moderateCount.toString(),
                Colors.orange,
                Icons.sentiment_neutral,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Şiddetli',
                severeCount.toString(),
                Colors.red,
                Icons.sentiment_dissatisfied,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'En Sık',
                AppStrings.tr(mostCommon),
                AppTheme.primaryColor,
                Icons.star,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePatterns() {
    if (_stats == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saatlik Dağılım',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildHourlyChart()),
            const SizedBox(height: 24),
            const Text(
              'Günlük Dağılım',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildWeeklyChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart() {
    final hourlyData = _stats!.severityByHour;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 3 != 0) return const SizedBox.shrink();
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(24, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: hourlyData[index].toDouble(),
                color: _getSeverityColorForValue(hourlyData[index]),
                width: 8,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final weeklyData = _stats!.severityByDay;
    final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= 7) {
                  return const SizedBox.shrink();
                }
                return Text(
                  dayNames[value.toInt()],
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklyData[index].toDouble(),
                color: _getSeverityColorForValue(weeklyData[index]),
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSeverityChart() {
    final mildCount = _stats?.mildCount ?? 0;
    final moderateCount = _stats?.moderateCount ?? 0;
    final severeCount = _stats?.severeCount ?? 0;
    final total = mildCount + moderateCount + severeCount;

    if (total == 0) {
      return const Card(
        child: Padding(padding: EdgeInsets.all(16.0), child: Text('Veri yok')),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: mildCount.toDouble(),
                        title:
                            '${((mildCount / total) * 100).toStringAsFixed(0)}%',
                        color: Colors.green,
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: moderateCount.toDouble(),
                        title:
                            '${((moderateCount / total) * 100).toStringAsFixed(0)}%',
                        color: Colors.orange,
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: severeCount.toDouble(),
                        title:
                            '${((severeCount / total) * 100).toStringAsFixed(0)}%',
                        color: Colors.red,
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem('Hafif', Colors.green, mildCount),
                  const SizedBox(height: 8),
                  _buildLegendItem('Orta', Colors.orange, moderateCount),
                  const SizedBox(height: 8),
                  _buildLegendItem('Şiddetli', Colors.red, severeCount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$label: $count', style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  IconData _getTriggerIcon(String type) {
    switch (type) {
      case 'weather':
        return Icons.wb_sunny;
      case 'location':
        return Icons.location_on;
      case 'time':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }

  Color _getTriggerColor(String type) {
    switch (type) {
      case 'weather':
        return Colors.blue;
      case 'location':
        return Colors.green;
      case 'time':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getSeverityColorForValue(int severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 6) return Colors.orange;
    return Colors.red;
  }
}
