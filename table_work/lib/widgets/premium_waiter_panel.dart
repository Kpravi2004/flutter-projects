import 'package:flutter/material.dart';
import '../models/waiter_model.dart';

class PremiumWaiterPanel extends StatelessWidget {
  final List<WaiterModel> waiters;
  final Function(WaiterModel) onWaiterSelected;
  final Color accentColor;

  const PremiumWaiterPanel({
    Key? key,
    required this.waiters,
    required this.onWaiterSelected,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Active Waitstaff',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: waiters.length,
            itemBuilder: (context, index) {
              final waiter = waiters[index];
              return _buildWaiterCard(waiter);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWaiterCard(WaiterModel waiter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: accentColor.withOpacity(0.2),
          backgroundImage: waiter.imageUrl != null
              ? AssetImage(waiter.imageUrl!) as ImageProvider
              : null,
          child: waiter.imageUrl == null
              ? Text(
            waiter.name[0],
            style: TextStyle(color: accentColor, fontSize: 18),
          )
              : null,
        ),
        title: Text(
          waiter.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text(
              waiter.rating.toString(),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(width: 12),
            Icon(Icons.receipt, color: accentColor, size: 14),
            const SizedBox(width: 4),
            Text(
              '${waiter.activeOrders} orders',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: waiter.isActive ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            waiter.isActive ? Icons.check : Icons.timer,
            color: Colors.white,
            size: 20,
          ),
        ),
        onTap: () => onWaiterSelected(waiter),
      ),
    );
  }
}