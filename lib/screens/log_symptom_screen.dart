import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/symptom_log.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../utils/app_strings.dart';
import '../utils/app_theme.dart';

class LogSymptomScreen extends StatefulWidget {
  const LogSymptomScreen({Key? key}) : super(key: key);

  @override
  State<LogSymptomScreen> createState() => _LogSymptomScreenState();
}

class _LogSymptomScreenState extends State<LogSymptomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DatabaseService();

  String? _selectedSymptomType;
  int _severity = 5;
  DateTime _selectedDateTime = DateTime.now();
  final _notesController = TextEditingController();

  // Location data
  double? _latitude;
  double? _longitude;
  String _locationName = 'Alınıyor...';
  bool _isLoadingLocation = true;

  // Weather data
  double? _temperature;
  double? _humidity;
  double? _windSpeed;
  String _weatherCondition = 'Alınıyor...';
  bool _isLoadingWeather = true;

  final List<String> _symptomTypes = [
    'runnyNose',
    'sneezing',
    'itchyEyes',
    'cough',
    'shortnessOfBreath',
    'skinRash',
    'swelling',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _getLocationAndWeather();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _getLocationAndWeather() async {
    // Get location first
    final locationData = await LocationService.getCurrentLocation();

    if (mounted) {
      setState(() {
        _isLoadingLocation = false;
        if (locationData != null) {
          _latitude = locationData['latitude'];
          _longitude = locationData['longitude'];
          _locationName = locationData['locationName'];
          print('🟢 [SCREEN] Location: $_locationName');
        } else {
          _locationName = 'Konum alınamadı';
        }
      });

      // Get weather using the location
      if (_latitude != null && _longitude != null) {
        _getWeather(_latitude!, _longitude!);
      }
    }
  }

  void _getWeather(double lat, double lon) async {
    final weather = await WeatherService.getWeather(lat, lon);

    if (mounted) {
      setState(() {
        _isLoadingWeather = false;
        if (weather != null) {
          _temperature = weather.temperature;
          _humidity = weather.humidity;
          _windSpeed = weather.windSpeed;
          _weatherCondition = weather.weatherCondition;
          print('🟢 [SCREEN] Weather: $_temperature°C, $_weatherCondition');
        } else {
          _weatherCondition = 'Hava durumu alınamadı';
        }
      });
    }
  }

  void _saveSymptom() async {
    if (_formKey.currentState!.validate() && _selectedSymptomType != null) {
      try {
        final symptom = SymptomLog(
          symptomType: _selectedSymptomType!,
          severity: _severity,
          notes: _notesController.text,
          dateTime: _selectedDateTime,
          latitude: _latitude,
          longitude: _longitude,
          locationName: _locationName,
          temperature: _temperature,
          humidity: _humidity,
          windSpeed: _windSpeed,
          weatherCondition: _weatherCondition,
        );

        await _dbService.insertSymptomLog(symptom);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.tr('symptomSaved')),
              backgroundColor: AppTheme.accentColor,
              duration: const Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) context.pop();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.tr('errorSavingSymptom')}: $e'),
              backgroundColor: AppTheme.dangerColor,
            ),
          );
        }
      }
    } else {
      if (_selectedSymptomType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.tr('pleaseSelectSymptom')),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr('logSymptom')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Konum',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_isLoadingLocation)
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Text(
                                  _locationName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Weather Card
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.cloud, color: Colors.orange, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hava Durumu',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_isLoadingWeather)
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _weatherCondition,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${_temperature?.toStringAsFixed(1)}°C • Nem: ${_humidity?.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  AppStrings.tr('symptomType'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(AppStrings.tr('selectSymptomType')),
                    ),
                    value: _selectedSymptomType,
                    items: _symptomTypes
                        .map(
                          (symptom) => DropdownMenuItem<String>(
                            value: symptom,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Text(AppStrings.tr(symptom)),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSymptomType = value),
                    underline: const SizedBox(),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  AppStrings.tr('severity'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _severity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: AppTheme.getSeverityColor(_severity),
                  onChanged: (value) =>
                      setState(() => _severity = value.toInt()),
                ),
                Card(
                  color: AppTheme.getSeverityColor(_severity),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppTheme.getSeverityIcon(_severity),
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_severity / 10',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _severity <= 3
                                  ? AppStrings.tr('mild')
                                  : _severity <= 6
                                  ? AppStrings.tr('moderate')
                                  : AppStrings.tr('severe'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  AppStrings.tr('time'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            '${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')}',
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDateTime,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null)
                              setState(
                                () => _selectedDateTime = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  _selectedDateTime.hour,
                                  _selectedDateTime.minute,
                                ),
                              );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                _selectedDateTime,
                              ),
                            );
                            if (picked != null)
                              setState(
                                () => _selectedDateTime = DateTime(
                                  _selectedDateTime.year,
                                  _selectedDateTime.month,
                                  _selectedDateTime.day,
                                  picked.hour,
                                  picked.minute,
                                ),
                              );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  AppStrings.tr('notes'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('addOptionalNotes'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: Text(AppStrings.tr('cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveSymptom,
                        child: Text(AppStrings.tr('save')),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
