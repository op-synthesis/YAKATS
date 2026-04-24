import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/yakats_logo.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../services/alert_service.dart';
import '../database/database_helper.dart';
import '../utils/app_theme.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserSettings _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final alertService = Provider.of<AlertService>(context, listen: false);
    setState(() {
      _settings = alertService.getSettings();
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final alertService = Provider.of<AlertService>(context, listen: false);
      await alertService.saveSettings(_settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [Text('✅ '), Text('Ayarlar kaydedildi')],
            ),
            backgroundColor: AppTheme.riskLow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppTheme.riskHigh,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundOf(context),
        title: Text(
          'Ayarlar',
          style: TextStyle(
            color: AppTheme.textPrimaryOf(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _saveSettings,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Appearance ──────────────────────────
                _sectionLabel(context, '🎨  Görünüm'),
                _buildBentoSection(
                  context,
                  bentoColor: BentoColor.lavender,
                  child: _buildThemeToggle(context, themeProvider),
                ),

                const SizedBox(height: 20),

                // ── Alerts ──────────────────────────────
                _sectionLabel(context, '🔔  Uyarı Ayarları'),
                _buildBentoSection(
                  context,
                  bentoColor: BentoColor.blue,
                  child: Column(
                    children: [
                      _buildSwitch(
                        context,
                        emoji: '🔔',
                        title: 'Uyarıları Etkinleştir',
                        subtitle: 'Risk tespitinde bildirim gönder',
                        value: _settings.enableAlerts,
                        onChanged: (val) => setState(() {
                          _settings = _settings.copyWith(enableAlerts: val);
                        }),
                      ),
                      _divider(context),
                      _buildSwitch(
                        context,
                        emoji: '⚠️',
                        title: 'Yüksek Risk Uyarısı',
                        subtitle: 'YÜKSEK ve CRİTİK için bildirim',
                        value: _settings.notifyOnHighRisk,
                        onChanged: _settings.enableAlerts
                            ? (val) => setState(() {
                                _settings = _settings.copyWith(
                                  notifyOnHighRisk: val,
                                );
                              })
                            : null,
                      ),
                      _divider(context),
                      _buildSwitch(
                        context,
                        emoji: 'ℹ️',
                        title: 'Orta Risk Uyarısı',
                        subtitle: 'ORTA risk için bildirim',
                        value: _settings.notifyOnMediumRisk,
                        onChanged: _settings.enableAlerts
                            ? (val) => setState(() {
                                _settings = _settings.copyWith(
                                  notifyOnMediumRisk: val,
                                );
                              })
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Risk Threshold
                _buildBentoSection(
                  context,
                  bentoColor: BentoColor.mint,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Risk Eşiği',
                              style: TextStyle(
                                color: AppTheme.textPrimaryOf(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '%${_settings.riskThreshold.toInt()}',
                              style: const TextStyle(
                                color: AppTheme.accentGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bu değerin üzerindeki riskler için uyarı gönderilir',
                        style: TextStyle(
                          color: AppTheme.textSecondOf(context),
                          fontSize: 12,
                        ),
                      ),
                      Slider(
                        value: _settings.riskThreshold,
                        min: 10,
                        max: 90,
                        divisions: 16,
                        label: '%${_settings.riskThreshold.toInt()}',
                        activeColor: AppTheme.accentGreen,
                        inactiveColor: AppTheme.accentGreen.withOpacity(0.2),
                        onChanged: _settings.enableAlerts
                            ? (val) => setState(() {
                                _settings = _settings.copyWith(
                                  riskThreshold: val,
                                );
                              })
                            : null,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '%10 Hassas',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.riskLow,
                            ),
                          ),
                          Text(
                            '%90 Katı',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.riskHigh,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Monitoring ──────────────────────────
                _sectionLabel(context, '📡  İzleme Ayarları'),
                _buildBentoSection(
                  context,
                  bentoColor: BentoColor.peach,
                  child: Column(
                    children: [
                      _buildSwitch(
                        context,
                        emoji: '🌤️',
                        title: 'Hava Durumu Takibi',
                        subtitle: 'Hava koşullarını dahil et',
                        value: _settings.checkWeather,
                        onChanged: (val) => setState(() {
                          _settings = _settings.copyWith(checkWeather: val);
                        }),
                      ),
                      _divider(context),
                      _buildSwitch(
                        context,
                        emoji: '📍',
                        title: 'Konum Takibi',
                        subtitle: 'Konumu risk hesabına dahil et',
                        value: _settings.checkLocation,
                        onChanged: (val) => setState(() {
                          _settings = _settings.copyWith(checkLocation: val);
                        }),
                      ),
                      _divider(context),
                      _buildSwitch(
                        context,
                        emoji: '⏰',
                        title: 'Zaman Örüntüsü',
                        subtitle: 'Zaman kalıplarını dahil et',
                        value: _settings.checkTime,
                        onChanged: (val) => setState(() {
                          _settings = _settings.copyWith(checkTime: val);
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Monitoring Interval
                _buildBentoSection(
                  context,
                  bentoColor: BentoColor.yellow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('⏱️', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Text(
                            'İzleme Sıklığı',
                            style: TextStyle(
                              color: AppTheme.textPrimaryOf(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Risk kontrolü ne sıklıkla yapılsın?',
                        style: TextStyle(
                          color: AppTheme.textSecondOf(context),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [5, 15, 30, 60].map((m) {
                          final selected = _settings.monitoringInterval == m;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _settings = _settings.copyWith(
                                monitoringInterval: m,
                              );
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.accentGold
                                    : AppTheme.accentGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '$m dk',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textSecondOf(context),
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Data Management ─────────────────────
                _sectionLabel(context, '🗄️  Veri Yönetimi'),
                _buildBentoSection(
                  context,
                  bentoColor: BentoColor.rose,
                  child: Column(
                    children: [
                      _buildActionRow(
                        context,
                        emoji: '🔕',
                        title: 'Tüm Uyarıları Temizle',
                        subtitle: 'Uyarı geçmişini sil',
                        onTap: () => _confirmDialog(
                          context,
                          title: 'Uyarıları Sil',
                          message: 'Tüm uyarı geçmişi silinecek. Emin misiniz?',
                          onConfirm: () async {
                            final s = Provider.of<AlertService>(
                              context,
                              listen: false,
                            );
                            await s.clearAllAlerts();
                          },
                        ),
                      ),
                      _divider(context),
                      _buildActionRow(
                        context,
                        emoji: '🗑️',
                        title: 'Tüm Verileri Sil',
                        subtitle: 'Semptom kayıtlarını ve uyarıları sil',
                        onTap: () => _confirmDialog(
                          context,
                          title: '⚠️ Tüm Verileri Sil',
                          message:
                              'TÜM veriler silinecek. Bu işlem geri alınamaz!',
                          onConfirm: () async {
                            final db = DatabaseHelper.instance;
                            await db.deleteAllSymptoms();
                            await db.deleteAllAlerts();
                          },
                          isDangerous: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── About ───────────────────────────────
                _sectionLabel(context, 'ℹ️  Hakkında'),
                _buildBentoSection(
                  context,
                  bentoColor: BentoColor.lavender,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // ── Arc only (no text inside) ──
                      YakatsLogo(size: 100, showText: false),

                      const SizedBox(height: 8),

                      // ── YAKATS text separate below arc ──
                      Text(
                        'YAKATS',
                        style: GoogleFonts.syncopate(
                          color: AppTheme.isDark(context)
                              ? const Color(0xFF4A6CF7)
                              : const Color(0xFF0F2A78),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Yapay Zeka Destekli Alerji Takip Sistemi',
                        style: TextStyle(
                          color: AppTheme.textSecondOf(context),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.accentGold.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          '✨  Versiyon 1.0.0',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Save button
                GestureDetector(
                  onTap: _isSaving ? null : _saveSettings,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.accentPurple, AppTheme.accentBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentPurple.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.save_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Ayarları Kaydet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════
  //  HELPER WIDGETS
  // ═══════════════════════════════════════════

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondOf(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBentoSection(
    BuildContext context, {
    required BentoColor bentoColor,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.bentoDecoration(context, bentoColor),
      child: child,
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    return Row(
      children: [
        Text(
          themeProvider.isDark ? '🌙' : '☀️',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                themeProvider.isDark ? 'Karanlık Tema' : 'Aydınlık Tema',
                style: TextStyle(
                  color: AppTheme.textPrimaryOf(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                themeProvider.isDark
                    ? 'Premium Obsidian aktif'
                    : 'Premium Pearl aktif',
                style: TextStyle(
                  color: AppTheme.textSecondOf(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: themeProvider.isDark,
          onChanged: (val) => themeProvider.setDark(val),
          activeColor: AppTheme.accentPurple,
        ),
      ],
    );
  }

  Widget _buildSwitch(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final disabled = onChanged == null;
    return Row(
      children: [
        Text(
          emoji,
          style: TextStyle(
            fontSize: 20,
            color: disabled ? AppTheme.textHintOf(context) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: disabled
                      ? AppTheme.textHintOf(context)
                      : AppTheme.textPrimaryOf(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.textSecondOf(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildActionRow(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimaryOf(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textSecondOf(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textHintOf(context),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 20,
      color: AppTheme.dividerOf(context).withOpacity(0.5),
    );
  }

  void _confirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDangerous = false,
  }) {
    final bentoType = isDangerous ? BentoColor.rose : BentoColor.blue;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bentoCardColor(context, bentoType),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          title,
          style: TextStyle(
            color: isDangerous
                ? AppTheme.riskHigh
                : AppTheme.textPrimaryOf(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppTheme.textSecondOf(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'İptal',
              style: TextStyle(color: AppTheme.textSecondOf(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(title),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous
                  ? AppTheme.riskHigh
                  : AppTheme.accentPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }
}
