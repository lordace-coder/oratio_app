import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oratio_app/bloc/booking_bloc/state.dart';
import 'package:pocketbase/pocketbase.dart';

class PaymentSuccesful extends StatelessWidget {
  const PaymentSuccesful({
    super.key,
    required this.bookingData,
    required this.bookingId,
  });

  final MassBookingData bookingData;
  final String bookingId;

  String _formatDate(DateTime? date) {
    if (date == null) return "Date not specified";
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[900]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Booking Confirmed!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildInfoCard(),
                          const SizedBox(height: 32),
                          _buildQRPlaceholder(),
                          const Spacer(),
                          _buildButtons(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(Icons.church, 'Church',
                bookingData.selectedChurch.getStringValue("name")),
            const Divider(height: 32),
            _buildInfoRow(Icons.calendar_today, 'Date',
                _formatDate(bookingData.selectedDate)),
            const Divider(height: 32),
            _buildInfoRow(Icons.access_time, 'Time',
                bookingData.getDateTime().toString()),
            const Divider(height: 32),
            _buildInfoRow(Icons.confirmation_number, 'Booking ID', bookingId),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
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

  Widget _buildQRPlaceholder() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.qr_code_2,
          size: 100,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Add download ticket functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Download Ticket',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Back to Home',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
