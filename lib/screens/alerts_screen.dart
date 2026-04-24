import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/alert_service.dart';
import '../models/alert_log.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<AlertLog> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final alertService = AlertService();
    final alerts = await alertService.getAlerts();
    setState(() {
      _alerts = alerts;
    });
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'CRİTİK':
        return Colors.red;
      case 'YÜKSEK':
        return Colors.orange;
      case 'ORTA':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uyarı Geçmişi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              final alertService = Provider.of<AlertService>(
                context,
                listen: false,
              );
              await alertService.markAllAsRead();
              await _loadAlerts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tüm uyarılar okundu olarak işaretlendi'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              _showClearConfirmationDialog();
            },
          ),
        ],
      ),
      body: _alerts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz uyarı yok',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text('Risk tespit edildiğinde burada görünecek'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  color: alert.isRead ? Colors.grey[100] : Colors.blue[50],
                  child: ListTile(
                    leading: Container(
                      width: 8,
                      color: _getRiskColor(alert.riskLevel),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                alert.title,
                                style: TextStyle(
                                  fontWeight: alert.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: _getRiskColor(alert.riskLevel),
                                ),
                              ),
                            ),
                            if (!alert.isRead)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'YENİ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          dateFormat.format(alert.dateTime),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(alert.message),
                        if (alert.triggers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: alert.triggers
                                  .take(3)
                                  .map(
                                    (trigger) => Chip(
                                      label: Text(
                                        trigger,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.grey[200],
                                      padding: const EdgeInsets.all(2),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '%${alert.riskScore.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getRiskColor(alert.riskLevel),
                          ),
                        ),
                        Text(
                          alert.riskLevel,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getRiskColor(alert.riskLevel),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showAlertDetails(alert);
                    },
                    onLongPress: () {
                      _showAlertActions(alert);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showAlertDetails(AlertLog alert) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Zaman: ${dateFormat.format(alert.dateTime)}'),
              Text('Risk Seviyesi: ${alert.riskLevel}'),
              Text('Risk Skoru: %${alert.riskScore.toStringAsFixed(1)}'),
              const SizedBox(height: 16),
              const Text(
                'Tetikleyiciler:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...alert.triggers.map(
                (trigger) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text('• $trigger'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mesaj:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(alert.message),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showAlertActions(AlertLog alert) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check),
            title: const Text('Okundu olarak işaretle'),
            onTap: () async {
              Navigator.pop(context);
              final alertService = Provider.of<AlertService>(
                context,
                listen: false,
              );
              await alertService.markAsRead(alert.id!);
              await _loadAlerts();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Sil'),
            onTap: () async {
              Navigator.pop(context);
              final alertService = Provider.of<AlertService>(
                context,
                listen: false,
              );
              await alertService.deleteAlert(alert.id!);
              await _loadAlerts();
            },
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Uyarıları Sil'),
        content: const Text(
          'Tüm uyarı geçmişini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final alertService = Provider.of<AlertService>(
                context,
                listen: false,
              );
              await alertService.clearAllAlerts();
              await _loadAlerts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm uyarılar silindi')),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
