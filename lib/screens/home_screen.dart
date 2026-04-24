import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/yakats_logo.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/symptom_log.dart';
import '../models/analytics_models.dart';
import '../services/database_service.dart';
import '../services/risk_prediction_service.dart';
import '../utils/app_theme.dart';
import '../utils/app_strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _dbService = DatabaseService();
  List<SymptomLog> _recentSymptoms = [];
  RiskAssessment? _currentRisk;
  bool _isLoading = true;
  bool _isCalculatingRisk = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadRecentSymptoms();
    _calculateRisk();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _loadRecentSymptoms() async {
    setState(() => _isLoading = true);
    try {
      final all = await _dbService.getAllSymptomLogs();
      all.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      if (mounted) {
        setState(() {
          _recentSymptoms = all.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔴 [HOME] $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateRisk() async {
    setState(() => _isCalculatingRisk = true);
    try {
      final all = await _dbService.getAllSymptomLogs();
      final risk = await RiskPredictionService.calculateRealTimeRisk(all);
      if (mounted) {
        setState(() {
          _currentRisk = risk;
          _isCalculatingRisk = false;
        });
        if (RiskPredictionService.shouldShowAlert(risk.riskLevel)) {
          _showRiskAlert(risk);
        }
      }
    } catch (e) {
      print('🔴 [HOME] Risk error: $e');
      if (mounted) setState(() => _isCalculatingRisk = false);
    }
  }

  void _showRiskAlert(RiskAssessment risk) {
    final bentoType = AppTheme.riskToBento(risk.riskLevel);
    final accent = AppTheme.bentoAccentColor(bentoType);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bentoCardColor(context, bentoType),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Text(
              RiskPredictionService.getRiskEmoji(risk.riskLevel),
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${risk.riskLevel} RİSK',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              RiskPredictionService.getRiskDescription(risk.riskLevel),
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimaryOf(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...risk.factors.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondOf(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            slivers: [
              // ── Header ────────────────────────────────
              // ── Header ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── YAKATS Logo (icon only, no text) ──
                      YakatsLogo(size: 44, showText: false),

                      const SizedBox(width: 8),

                      // ── YAKATS text separate ──────────────
                      // ✅ Replace with:
                      Text(
                        'YAKATS',
                        style: GoogleFonts.syncopate(
                          color: AppTheme.isDark(context)
                              ? const Color(0xFF4A6CF7)
                              : const Color(0xFF0F2A78),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),

                      const Spacer(),

                      // ── Icon buttons ──────────────────────
                      _buildIconButton(
                        context,
                        icon: Icons.refresh_rounded,
                        onTap: () {
                          _loadRecentSymptoms();
                          _calculateRisk();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        context,
                        icon: Icons.settings_rounded,
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Greeting below logo ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    _greetingText(),
                    style: GoogleFonts.syncopate(
                      fontSize: 11,
                      color: AppTheme.textSecondOf(context),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              // ── Bento Grid ────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Row 1: Risk Hero (full width)
                    _buildRiskHeroBento(context),

                    const SizedBox(height: 14),

                    // Row 2: Log + History
                    Row(
                      children: [
                        Expanded(
                          child: _buildBentoAction(
                            context,
                            title: 'Semptom\nKaydet',
                            emoji: '📝',
                            bentoColor: BentoColor.lavender,
                            height: 150,
                            onTap: () => context.push('/log-symptom').then((_) {
                              _loadRecentSymptoms();
                              _calculateRisk();
                            }),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildBentoAction(
                            context,
                            title: 'Geçmiş\nKayıtlar',
                            emoji: '📅',
                            bentoColor: BentoColor.blue,
                            height: 150,
                            onTap: () => context.push('/history'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Row 3: Insights + Alerts
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildBentoAction(
                            context,
                            title: 'Yapay Zeka\nİçgörüleri',
                            emoji: '🧠',
                            bentoColor: BentoColor.peach,
                            height: 130,
                            onTap: () => context.push('/insights'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: _buildBentoAction(
                            context,
                            title: 'Uyarılar',
                            emoji: '🔔',
                            bentoColor: BentoColor.yellow,
                            height: 130,
                            onTap: () => context.push('/alerts'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Recent Activity Section ────────────
                    Text(
                      'Son Aktivite',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryOf(context),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _isLoading
                        ? _buildSkeletonCard(context)
                        : _recentSymptoms.isEmpty
                        ? _buildEmptyState(context)
                        : _buildRecentList(context),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),

      // FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [AppTheme.accentPurple, AppTheme.accentBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentPurple.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => context.push('/log-symptom').then((_) {
              _loadRecentSymptoms();
              _calculateRisk();
            }),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.tr('logSymptom'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Greeting ──────────────────────────────────────────────────
  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın ☀️';
    if (hour < 18) return 'İyi günler 🌤️';
    return 'İyi akşamlar 🌙';
  }

  // ── Icon Button ───────────────────────────────────────────────
  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderOf(context)),
        ),
        child: Icon(icon, size: 20, color: AppTheme.textPrimaryOf(context)),
      ),
    );
  }

  // ── Risk Hero Bento ───────────────────────────────────────────
  Widget _buildRiskHeroBento(BuildContext context) {
    if (_isCalculatingRisk) {
      return _buildSkeletonCard(context, height: 180);
    }

    final risk = _currentRisk;
    final bentoType = risk != null
        ? AppTheme.riskToBento(risk.riskLevel)
        : BentoColor.blue;
    final accent = AppTheme.bentoAccentColor(bentoType);

    return GestureDetector(
      onTap: () => context.push('/risk-details'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.gradientCard(context, bentoType),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'CANLI RİSK',
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.textHintOf(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Score row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  risk != null ? '%${risk.riskScore.toInt()}' : '—',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryOf(context),
                    height: 1,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        risk?.riskLevel ?? 'Hesaplanıyor',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      risk != null
                          ? RiskPredictionService.getRiskEmoji(risk.riskLevel)
                          : '⏳',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              ],
            ),

            if (risk != null) ...[
              const SizedBox(height: 14),
              Text(
                RiskPredictionService.getRiskDescription(risk.riskLevel),
                style: TextStyle(
                  color: AppTheme.textSecondOf(context),
                  fontSize: 13,
                ),
              ),

              if (risk.factors.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: risk.factors.take(3).map((f) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ── Bento Action Card ─────────────────────────────────────────
  Widget _buildBentoAction(
    BuildContext context, {
    required String title,
    required String emoji,
    required BentoColor bentoColor,
    required VoidCallback onTap,
    double height = 150,
  }) {
    final accent = AppTheme.bentoAccentColor(bentoColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.bentoDecoration(context, bentoColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryOf(context),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Skeleton Loading Card ─────────────────────────────────────
  Widget _buildSkeletonCard(BuildContext context, {double height = 120}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.borderOf(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryOf(context),
          strokeWidth: 2,
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.bentoDecoration(context, BentoColor.blue),
      child: Column(
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Henüz semptom kaydı yok',
            style: TextStyle(
              color: AppTheme.textPrimaryOf(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Semptom kaydetmek için aşağıdaki butona basın',
            style: TextStyle(
              color: AppTheme.textSecondOf(context),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Recent Activity List ──────────────────────────────────────
  Widget _buildRecentList(BuildContext context) {
    final timeFormat = DateFormat('HH:mm', 'tr');
    final dateFormat = DateFormat('dd MMM', 'tr');

    return Column(
      children: _recentSymptoms.map((symptom) {
        final severity = symptom.severity;
        final color = AppTheme.getSeverityColor(severity);

        BentoColor bentoType;
        if (severity <= 3) {
          bentoType = BentoColor.mint;
        } else if (severity <= 6) {
          bentoType = BentoColor.yellow;
        } else {
          bentoType = BentoColor.rose;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.bentoDecoration(context, bentoType),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _severityEmoji(severity),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.tr(symptom.symptomType),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimaryOf(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dateFormat.format(symptom.dateTime)} • ${timeFormat.format(symptom.dateTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondOf(context),
                      ),
                    ),
                    if (symptom.weatherCondition != null)
                      Text(
                        '${symptom.weatherCondition} • ${symptom.temperature?.toStringAsFixed(0)}°C',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textHintOf(context),
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
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${severity}/10',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _severityEmoji(int severity) {
    if (severity <= 3) return '😊';
    if (severity <= 6) return '😐';
    return '😰';
  }
}
