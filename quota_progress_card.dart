import 'package:flutter/material.dart';
import '../../data/models/user_session_model.dart';

class QuotaProgressCard extends StatelessWidget {
  final UserSessionModel session;

  const QuotaProgressCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'REMAINING DATA QUOTA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: session.isActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  session.isActive ? 'ACTIVE' : 'DISABLED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: session.isActive ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${session.remainingGb.toStringAsFixed(2)} GB',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00E5FF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Used ${session.usedGb.toStringAsFixed(2)} GB of ${session.totalGb.toStringAsFixed(2)} GB total',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: session.usageRatio,
              minHeight: 10,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                session.usageRatio > 0.85 ? Colors.redAccent : const Color(0xFF00E5FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
