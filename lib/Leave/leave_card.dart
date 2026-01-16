
import 'package:flutter/material.dart';


@override
class LeaveCard extends StatelessWidget {
  final Color? color;
  final String title;
  final IconData icon;
  final double balance;
  final double used;
  final VoidCallback onTap;

  LeaveCard({
    required this.color,
    required this.title,
    required this.icon,
    required this.balance,
    required this.used,
    required this.onTap,
  });

   

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Balance: $balance'),
                Text('Used: $used'),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}