import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/symptom_log.dart';
import '../services/database_service.dart';
import '../utils/app_strings.dart';
import '../utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _dbService = DatabaseService();
  List<SymptomLog> _allSymptoms = [];
  List<SymptomLog> _filteredSymptoms = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  void _loadSymptoms() async {
    setState(() => _isLoading = true);

    try {
      final symptoms = await _dbService.getAllSymptomLogs();

      // Sort by date descending (newest first)
      symptoms.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      if (mounted) {
        setState(() {
          _allSymptoms = symptoms;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔴 [HISTORY] Error loading symptoms: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    final now = DateTime.now();

    setState(() {
      switch (_selectedFilter) {
        case 'today':
          _filteredSymptoms = _allSymptoms.where((s) {
            return s.dateTime.year == now.year &&
                s.dateTime.month == now.month &&
                s.dateTime.day == now.day;
          }).toList();
          break;
        case 'yesterday':
          final yesterday = now.subtract(const Duration(days: 1));
          _filteredSymptoms = _allSymptoms.where((s) {
            return s.dateTime.year == yesterday.year &&
                s.dateTime.month == yesterday.month &&
                s.dateTime.day == yesterday.day;
          }).toList();
          break;
        case 'thisWeek':
          final weekAgo = now.subtract(const Duration(days: 7));
          _filteredSymptoms = _allSymptoms.where((s) {
            return s.dateTime.isAfter(weekAgo);
          }).toList();
          break;
        case 'thisMonth':
          final monthAgo = now.subtract(const Duration(days: 30));
          _filteredSymptoms = _allSymptoms.where((s) {
            return s.dateTime.isAfter(monthAgo);
          }).toList();
          break;
        default:
          _filteredSymptoms = _allSymptoms;
      }
    });
  }

  void _deleteSymptom(SymptomLog symptom) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.tr('delete')),
        content: Text(AppStrings.tr('deleteConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.tr('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && symptom.id != null) {
      await _dbService.deleteSymptomLog(symptom.id!);
      _loadSymptoms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.tr('symptomDeleted')),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  void _showSymptomDetails(SymptomLog symptom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildDetailsSheet(symptom),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr('history')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSymptoms),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistics Card
                _buildStatsCard(),

                // Filter chips
                _buildFilterChips(),

                // Symptoms list
                Expanded(
                  child: _filteredSymptoms.isEmpty
                      ? _buildEmptyState()
                      : _buildSymptomsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCard() {
    final total = _filteredSymptoms.length;
    final avgSeverity = total > 0
        ? _filteredSymptoms.map((s) => s.severity).reduce((a, b) => a + b) /
              total
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppStrings.tr('totalSymptoms'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: Column(
              children: [
                Text(
                  avgSeverity.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppStrings.tr('avgSeverity'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': AppStrings.tr('all')},
      {'key': 'today', 'label': AppStrings.tr('today')},
      {'key': 'yesterday', 'label': AppStrings.tr('yesterday')},
      {'key': 'thisWeek', 'label': AppStrings.tr('thisWeek')},
      {'key': 'thisMonth', 'label': AppStrings.tr('thisMonth')},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];

          return ChoiceChip(
            label: Text(filter['label']!),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedFilter = filter['key']!;
                });
                _applyFilter();
              }
            },
            selectedColor: AppTheme.primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            AppStrings.tr('noSymptomsLogged'),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSymptoms.length,
      itemBuilder: (context, index) {
        final symptom = _filteredSymptoms[index];
        return _buildSymptomCard(symptom);
      },
    );
  }

  Widget _buildSymptomCard(SymptomLog symptom) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSymptomDetails(symptom),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Symptom type + Severity
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.getSeverityColor(
                      symptom.severity,
                    ),
                    child: Icon(
                      AppTheme.getSeverityIcon(symptom.severity),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr(symptom.symptomType),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${dateFormat.format(symptom.dateTime)} • ${timeFormat.format(symptom.dateTime)}',
                          style: TextStyle(
                            fontSize: 12,
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
                      color: AppTheme.getSeverityColor(symptom.severity),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${symptom.severity}/10',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Location and weather row
              Row(
                children: [
                  if (symptom.locationName != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              symptom.locationName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (symptom.temperature != null) ...[
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(Icons.thermostat, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${symptom.temperature!.toStringAsFixed(0)}°C',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              if (symptom.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    symptom.notes,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSheet(SymptomLog symptom) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr');
    final timeFormat = DateFormat('HH:mm');

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                AppStrings.tr('symptomDetails'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Symptom type with icon
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.getSeverityColor(
                      symptom.severity,
                    ),
                    child: Icon(
                      AppTheme.getSeverityIcon(symptom.severity),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr(symptom.symptomType),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Şiddet: ${symptom.severity}/10',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.getSeverityColor(symptom.severity),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Date & Time
              _buildDetailRow(
                Icons.calendar_today,
                'Tarih',
                '${dateFormat.format(symptom.dateTime)} • ${timeFormat.format(symptom.dateTime)}',
              ),

              // Location
              if (symptom.locationName != null) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.location_on,
                  AppStrings.tr('location'),
                  symptom.locationName!,
                ),
              ],

              // GPS coordinates
              if (symptom.latitude != null && symptom.longitude != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    'GPS: ${symptom.latitude!.toStringAsFixed(4)}, ${symptom.longitude!.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],

              // Weather details
              if (symptom.weatherCondition != null) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.cloud,
                  AppStrings.tr('weather'),
                  symptom.weatherCondition!,
                ),
              ],

              // Temperature
              if (symptom.temperature != null) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.thermostat,
                  AppStrings.tr('temperature'),
                  '${symptom.temperature!.toStringAsFixed(1)}°C',
                ),
              ],

              // Humidity
              if (symptom.humidity != null) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.water_drop,
                  AppStrings.tr('humidity'),
                  '${symptom.humidity!.toStringAsFixed(0)}%',
                ),
              ],

              // Notes
              if (symptom.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.notes,
                  AppStrings.tr('notes'),
                  symptom.notes,
                ),
              ],

              const SizedBox(height: 24),

              // Delete button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteSymptom(symptom);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: Text(
                    AppStrings.tr('delete'),
                    style: const TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
