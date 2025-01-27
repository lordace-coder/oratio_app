import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shimmer/shimmer.dart';

const String DEFAULT_MASS_TYPE = 'Regular Mass';

class MassBooking {
  final String id;
  final String parish;
  final DateTime time;
  final String intention;
  final List<String> attendees;
  final String bookedBy;
  final double donationAmount;
  final String? massType;
  MassStatus status;

  MassBooking({
    required this.id,
    required this.parish,
    required this.time,
    required this.intention,
    required this.attendees,
    required this.bookedBy,
    required this.donationAmount,
    this.massType,
    this.status = MassStatus.pending,
  });

  String get displayMassType => massType ?? DEFAULT_MASS_TYPE;
}

enum MassStatus { pending, accepted, rejected }

class BookedMassesPage extends StatefulWidget {
  const BookedMassesPage({super.key});

  @override
  _BookedMassesPageState createState() => _BookedMassesPageState();
}

class _BookedMassesPageState extends State<BookedMassesPage> {
  bool _isLoading = true;
  String? _error;
  final List<MassBooking> _massBookings = [];
  RecordModel? myParish;

  @override
  void initState() {
    super.initState();
    loadChurchForPriest();
    _fetchMassBookings();
  }

  Future<void> loadChurchForPriest() async {
    final pb = getPocketBaseFromContext(context);
    final userId = pb.authStore.model.id;
    try {
      final record = await pb.collection('parish').getFirstListItem(
            'priest = "$userId"',
          );
      setState(() {
        myParish = record;
      });
    } catch (e) {
      print('Error fetching parish: $e');
    }
    final profile = context.read<ProfileDataCubit>();
    await profile.getMyProfile();
  }

  Future<void> _fetchMassBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      if (myParish == null) {
        await loadChurchForPriest();
      }

      final pb = getPocketBaseFromContext(context);
      final data = await pb.collection('mass_booking').getList(
          filter: 'parish ="${myParish!.id}"',
          expand: 'user, donation , parish');
      // Simulate network delay

      final List<MassBooking> bookings = data.items.map((z) {
        var i = z.data;
        MassStatus status = MassStatus.pending;

        if (i['confirmed'] == true) {
          status = MassStatus.accepted;
        } else if (i['confirmed'] == false && i['used_callback'] == true) {
          status = MassStatus.rejected;
        }
        return MassBooking(
          id: z.id,
          parish: z.expand['parish']!.first.getStringValue('name'),
          time: DateTime.parse(z.getStringValue('time')),
          intention: i['intention'],
          attendees: [i['attendees']],
          bookedBy: getFullName(z.expand['user']!.first),
          donationAmount: z.expand['donation']!.first.getDoubleValue('amount'),
          massType: i['mass_type'] as String?, // Make nullable
          status: status,
        );
      }).toList();

      setState(() {
        _massBookings.clear();
        _massBookings.addAll(bookings);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load mass bookings. Please try again.';
        _isLoading = false;
      });
      rethrow;
    }
  }

  void _showMassDetailsModal(MassBooking mass) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mass Details',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.church_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mass.parish,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMMM d, yyyy • h:mm a')
                                  .format(mass.time),
                              style: GoogleFonts.nunito(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildDetailSection(
                    'Intention',
                    mass.intention,
                    Icons.description_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailSection(
                    'Mass Type',
                    mass.displayMassType, // Use the getter instead of direct access
                    Icons.category_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailSection(
                    'Booked By',
                    mass.bookedBy,
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailSection(
                    'Donation',
                    '₦${mass.donationAmount.toStringAsFixed(2)}',
                    Icons.payments_outlined,
                  ),
                  const SizedBox(height: 25),
                  _buildAttendeesSection(mass.attendees),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _updateMassStatus(mass, MassStatus.accepted),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Accept',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _updateMassStatus(mass, MassStatus.rejected),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: AppColors.error),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Reject',
                            style: GoogleFonts.nunito(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
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

  Widget _buildDetailSection(String title, String content, IconData icon) {
    if (title == 'Mass Type' && content.isEmpty) {
      content = DEFAULT_MASS_TYPE;
    }
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesSection(List<String> attendees) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.people_outline, color: AppColors.primary),
              ),
              const SizedBox(width: 15),
              Text(
                'Attendees (${attendees.length})',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...attendees.map((attendee) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 10),
                    Text(
                      attendee,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _updateMassStatus(MassBooking mass, MassStatus status) async {
    try {
      if (status == MassStatus.accepted) {
        await acceptMassRequest(context, mass.id);
      } else {
        await declineMassRequest(context, mass.id);
      }
      NotificationService.showSuccess('Booking updated successfully');
    } catch (e) {
      return NotificationService.showError('Failed to update status');
    }
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

  Widget _buildLoadingCard() {
    return Card(
      elevation: 8,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 140,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: 100,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 32,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: GoogleFonts.nunito(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchMassBookings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Colors.white), // Makes back button white
        title: Column(
          children: [
            Text(
              'Mass Bookings',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
            Text(
              '${_massBookings.length} Bookings',
              style: GoogleFonts.nunito(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
                AppColors.blue,
              ],
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // Add filter functionality here
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary.withOpacity(0.1), AppColors.appBg],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _fetchMassBookings,
            child: _error != null
                ? _buildErrorView()
                : ListView.builder(
                    padding:
                        EdgeInsets.fromLTRB(16, statusBarHeight + 16, 16, 16),
                    itemCount: _isLoading ? 3 : _massBookings.length,
                    itemBuilder: (context, index) {
                      if (_isLoading) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildLoadingCard(),
                        );
                      }

                      final mass = _massBookings[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          elevation: 8,
                          shadowColor: AppColors.shadow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _showMassDetailsModal(mass),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.event,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          DateFormat('MMMM d, yyyy • h:mm a')
                                              .format(mass.time),
                                          style: GoogleFonts.nunito(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      _buildStatusBadge(mass.status),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Intention:',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mass.intention,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(Icons.people,
                                          size: 20, color: AppColors.purple),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${mass.attendees.length} Attendees',
                                        style: GoogleFonts.nunito(
                                          color: AppColors.purple,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '₦${mass.donationAmount.toStringAsFixed(2)}',
                                        style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MassStatus status) {
    Color color;
    String text;

    switch (status) {
      case MassStatus.pending:
        color = AppColors.pending;
        text = 'Pending';
        break;
      case MassStatus.accepted:
        color = AppColors.success;
        text = 'Accepted';
        break;
      case MassStatus.rejected:
        color = AppColors.error;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
