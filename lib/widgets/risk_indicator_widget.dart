import 'package:flutter/material.dart';
import '../models/analytics_models.dart';
import '../services/risk_prediction_service.dart';

class RiskIndicatorWidget extends StatelessWidget {
  final RiskAssessment risk;
  final VoidCallback? onTap;

  const RiskIndicatorWidget({Key? key, required this.risk, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = RiskPredictionService.getRiskColor(risk.riskLevel);
    final icon = RiskPredictionService.getRiskIcon(risk.riskLevel);
    final emoji = RiskPredictionService.getRiskEmoji(risk.riskLevel);
    final description = RiskPredictionService.getRiskDescription(
      risk.riskLevel,
    );

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          // ✅ Changed from border to shape
          side: BorderSide(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with emoji and risk level
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Güncel Risk',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          risk.riskLevel,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
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
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${risk.riskScore.toStringAsFixed(0)}/100',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Risk description
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // Risk factors
              if (risk.factors.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Etki Eden Faktörler:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: risk.factors
                          .map(
                            (factor) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      factor,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // Time of assessment
              Text(
                'Güncellenme: ${TimeOfDay.fromDateTime(risk.assessmentTime).format(context)}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
