import 'package:flutter/material.dart';
import 'package:oratio_app/ui/themes.dart';

class DashboardButton extends StatelessWidget {
  const DashboardButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
          Text(
            text,
            style: TextStyle(color: AppColors.primary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mass Booking'),
                Text(
                  'Nov 17',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('₦400.00'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.greenDisabled.withOpacity(.2)),
                  child: Text('Successful',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 10,
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
