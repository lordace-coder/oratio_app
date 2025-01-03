import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MassBooking {
  final String id;
  final String parish;
  final DateTime time;
  final String intention;
  final List<String> attendees;
  final String bookedBy;
  final double donationAmount;
  final String massType;
  MassStatus status;

  MassBooking({
    required this.id,
    required this.parish,
    required this.time,
    required this.intention,
    required this.attendees,
    required this.bookedBy,
    required this.donationAmount,
    required this.massType,
    this.status = MassStatus.pending,
  });
}

enum MassStatus { pending, accepted, rejected }

class BookedMassesPage extends StatefulWidget {
  const BookedMassesPage({super.key});

  @override
  _BookedMassesPageState createState() => _BookedMassesPageState();
}

class _BookedMassesPageState extends State<BookedMassesPage> {
  final List<MassBooking> _massBookings = [
    MassBooking(
      id: '001',
      parish: "St. Mary's Cathedral",
      time: DateTime(2024, 3, 15, 9, 0),
      intention:
          'For the repose of the soul of John Smith, a longtime parishioner who dedicated his life to community service and faith',
      attendees: ['Mary Smith', 'James Smith', 'Elizabeth Jones'],
      bookedBy: 'Mary Smith',
      donationAmount: 50.00,
      massType: 'Memorial Mass',
    ),
    // More sample data...
  ];

  void _showMassDetailsModal(MassBooking mass) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              spreadRadius: 5,
            )
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF4A184C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mass Details',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildDetailRow('Parish', mass.parish),
                  _buildDetailRow(
                      'Date', DateFormat('MMMM d, yyyy').format(mass.time)),
                  _buildDetailRow(
                      'Time', DateFormat('h:mm a').format(mass.time)),
                  _buildDetailRow('Intention', mass.intention),
                  _buildDetailRow('Mass Type', mass.massType),
                  _buildDetailRow('Booked By', mass.bookedBy),
                  _buildDetailRow('Donation',
                      '\$${mass.donationAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 20),
                  Text(
                    'Attendees',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A184C),
                    ),
                  ),
                  ...mass.attendees.map((attendee) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          attendee,
                          style: GoogleFonts.nunito(fontSize: 16),
                        ),
                      )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            _updateMassStatus(mass, MassStatus.accepted),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Accept',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _updateMassStatus(mass, MassStatus.rejected),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  void _updateMassStatus(MassBooking mass, MassStatus status) {
    setState(() {
      mass.status = status;
    });
    Navigator.pop(context);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.deepPurple,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mass Bookings',
          style: GoogleFonts.nunito(
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A184C),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _massBookings.length,
        itemBuilder: (context, index) {
          final mass = _massBookings[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Text(
                mass.intention,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A184C),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Parish: ${mass.parish}',
                    style: GoogleFonts.nunito(color: Colors.black87),
                  ),
                  Text(
                    'Date: ${DateFormat('MMMM d, yyyy').format(mass.time)}',
                    style: GoogleFonts.nunito(color: Colors.black87),
                  ),
                ],
              ),
              trailing: _buildStatusIndicator(mass.status),
              onTap: () => _showMassDetailsModal(mass),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(MassStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case MassStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case MassStatus.accepted:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case MassStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Icon(icon, color: color);
  }
}
