import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ace_toast/ace_toast.dart';
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

  // Add tracking for debugging
  void _trackError(String location, dynamic error, [StackTrace? stackTrace]) {
    print('🔴 ERROR at $location: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }

  void _trackInfo(String location, String message) {
    print('ℹ️ INFO at $location: $message');
  }

  void _trackData(String location, dynamic data) {
    print('📊 DATA at $location: $data');
  }

  @override
  void initState() {
    super.initState();
    _trackInfo('initState', 'Initializing BookedMassesPage');
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await loadChurchForPriest();
      await _fetchMassBookings();
    } catch (e, stackTrace) {
      _trackError('_initializeData', e, stackTrace);
      setState(() {
        _error = 'Failed to initialize data. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> loadChurchForPriest() async {
    _trackInfo('loadChurchForPriest', 'Starting to load church for priest');

    try {
      final pb = getPocketBaseFromContext(context);
      final userId = pb.authStore.model?.id;

      if (userId == null) {
        throw Exception('User ID not found in auth store');
      }

      _trackData('loadChurchForPriest', 'User ID: $userId');

      // Check the exact filter syntax - this might be the issue
      final record = await pb.collection('parish').getFirstListItem(
            'priest="$userId"', // Removed spaces around the = sign
          );

      _trackData('loadChurchForPriest', 'Parish record found');

      setState(() {
        myParish = record;
      });

      // Handle profile loading separately to avoid cascade failures
      try {
        final profile = context.read<ProfileDataCubit>();
        await profile.getMyProfile();
        _trackInfo(
            'loadChurchForPriest', 'Successfully loaded church and profile');
      } catch (profileError) {
        _trackError('loadChurchForPriest',
            'Profile loading failed but continuing: $profileError');
        // Continue execution even if profile fails
      }
    } catch (e, stackTrace) {
      _trackError('loadChurchForPriest', e, stackTrace);

      // Since other pages work, this is likely a request-specific issue
      if (e.toString().contains('ClientException')) {
        throw Exception('Request failed. Check filter syntax or field names.');
      }

      rethrow;
    }
  }

  Future<void> _fetchMassBookings() async {
    _trackInfo('_fetchMassBookings', 'Starting to fetch mass bookings');

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (myParish == null) {
        _trackInfo('_fetchMassBookings', 'Parish not loaded, loading first');
        await loadChurchForPriest();
      }

      if (myParish == null) {
        throw Exception('No parish found for current priest');
      }

      final pb = getPocketBaseFromContext(context);
      _trackData('_fetchMassBookings', 'Parish ID: ${myParish!.id}');

      // Keep your original request structure with corrected filter syntax
      final data = await pb.collection('mass_booking').getList(
            filter: 'parish="${myParish!.id}"', // Removed spaces around = sign
            expand: 'user,donation,parish', // Removed spaces after commas
          );

      _trackData(
          '_fetchMassBookings', 'Raw data items count: ${data.items.length}');

      final List<MassBooking> bookings = [];

      for (int index = 0; index < data.items.length; index++) {
        try {
          final item = data.items[index];
          _trackData(
              '_fetchMassBookings', 'Processing item $index: ${item.id}');

          final booking = _createMassBookingFromRecord(item);
          bookings.add(booking);
          _trackInfo('_fetchMassBookings',
              'Successfully processed booking: ${booking.id}');
        } catch (e, stackTrace) {
          _trackError('_fetchMassBookings', 'Error processing item $index: $e',
              stackTrace);
          // Continue processing other items instead of failing completely
          continue;
        }
      }

      setState(() {
        _massBookings.clear();
        _massBookings.addAll(bookings);
        _isLoading = false;
      });

      _trackInfo('_fetchMassBookings',
          'Successfully fetched ${bookings.length} mass bookings');
    } catch (e, stackTrace) {
      _trackError('_fetchMassBookings', e, stackTrace);

      String errorMessage = 'Failed to load mass bookings. Please try again.';

      // Provide specific error messages for common network issues
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('SocketException')) {
        errorMessage =
            'No internet connection. Please check your network and try again.';
      } else if (e.toString().contains('ClientException')) {
        errorMessage = 'Server connection failed. Please try again later.';
      } else if (e.toString().contains('No parish found')) {
        errorMessage =
            'No parish assigned to your account. Please contact administrator.';
      }

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  MassBooking _createMassBookingFromRecord(RecordModel record) {
    try {
      final data = record.data;
      _trackData(
          '_createMassBookingFromRecord', 'Record data: ${data.toString()}');

      // Safe extraction with type checking and null safety
      MassStatus status = MassStatus.pending;
      final confirmed = data['confirmed'];
      final usedCallback = data['used_callback'];

      if (confirmed == true) {
        status = MassStatus.accepted;
      } else if (confirmed == false && usedCallback == true) {
        status = MassStatus.rejected;
      }

      // Extract parish name safely
      String parishName = 'Unknown Parish';
      try {
        final parishExpand = record.expand['parish'];
        if (parishExpand != null && parishExpand.isNotEmpty) {
          parishName = parishExpand.first.getStringValue('name');
        }
      } catch (e) {
        _trackError(
            '_createMassBookingFromRecord', 'Error extracting parish name: $e');
      }

      // Extract user name safely
      String bookedByName = 'Unknown User';
      try {
        final userExpand = record.expand['user'];
        if (userExpand != null && userExpand.isNotEmpty) {
          bookedByName = getFullName(userExpand.first);
        }
      } catch (e) {
        _trackError(
            '_createMassBookingFromRecord', 'Error extracting user name: $e');
      }

      // Extract donation amount safely
      double donationAmount = 0.0;
      try {
        final donationExpand = record.expand['donation'];
        if (donationExpand != null && donationExpand.isNotEmpty) {
          donationAmount = donationExpand.first.getDoubleValue('amount');
        }
      } catch (e) {
        _trackError('_createMassBookingFromRecord',
            'Error extracting donation amount: $e');
      }

      // Extract attendees safely
      List<String> attendees = [];
      try {
        final attendeesData = data['attendees'];
        if (attendeesData != null) {
          if (attendeesData is String) {
            attendees = [attendeesData];
          } else if (attendeesData is List) {
            attendees = attendeesData.map((e) => e.toString()).toList();
          }
        }
      } catch (e) {
        _trackError(
            '_createMassBookingFromRecord', 'Error extracting attendees: $e');
        attendees = ['Unknown'];
      }

      // Extract time safely - for now using current time, but you should parse the actual time
      DateTime massTime = DateTime.now();
      try {
        final timeData =
            data['time'] ?? data['scheduled_time'] ?? data['date_time'];
        if (timeData != null) {
          if (timeData is String) {
            massTime = DateTime.tryParse(timeData) ?? DateTime.now();
          }
        }
      } catch (e) {
        _trackError(
            '_createMassBookingFromRecord', 'Error extracting time: $e');
      }

      final booking = MassBooking(
        id: record.id,
        parish: parishName,
        time: massTime,
        intention: data['intention']?.toString() ?? 'No intention specified',
        attendees: attendees,
        bookedBy: bookedByName,
        donationAmount: donationAmount,
        massType: data['mass_type']?.toString(),
        status: status,
      );

      _trackData(
          '_createMassBookingFromRecord', 'Created booking: ${booking.id}');
      return booking;
    } catch (e, stackTrace) {
      _trackError('_createMassBookingFromRecord', e, stackTrace);
      rethrow;
    }
  }

  void _showMassDetailsModal(MassBooking mass) {
    _trackInfo('_showMassDetailsModal', 'Showing details for mass: ${mass.id}');

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
            // Enhanced header with gradient
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
                    mass.displayMassType,
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
                  if (mass.status == MassStatus.pending) ...[
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
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Accept',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
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
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close, color: AppColors.error),
                                const SizedBox(width: 8),
                                Text(
                                  'Reject',
                                  style: GoogleFonts.nunito(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: _getStatusColor(mass.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _getStatusColor(mass.status)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            mass.status == MassStatus.accepted
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _getStatusColor(mass.status),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mass.status == MassStatus.accepted
                                ? 'Already Accepted'
                                : 'Already Rejected',
                            style: GoogleFonts.nunito(
                              color: _getStatusColor(mass.status),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(MassStatus status) {
    switch (status) {
      case MassStatus.pending:
        return AppColors.pending;
      case MassStatus.accepted:
        return AppColors.success;
      case MassStatus.rejected:
        return AppColors.error;
    }
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

  Future<void> _updateMassStatus(MassBooking mass, MassStatus status) async {
    _trackInfo('_updateMassStatus', 'Updating mass ${mass.id} to $status');

    try {
      if (status == MassStatus.accepted) {
        await acceptMassRequest(context, mass.id);
      } else {
        await declineMassRequest(context, mass.id);
      }

      setState(() {
        mass.status = status;
      });

      Navigator.pop(context);
      NotificationService.showSuccess('Booking updated successfully');
      _trackInfo('_updateMassStatus', 'Successfully updated mass status');
    } catch (e, stackTrace) {
      _trackError('_updateMassStatus', e, stackTrace);
      NotificationService.showError('Failed to update status');
    }
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _error?.contains('internet') == true ||
                        _error?.contains('network') == true
                    ? Icons.wifi_off
                    : _error?.contains('Server') == true
                        ? Icons.cloud_off
                        : Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'An error occurred',
              style: GoogleFonts.nunito(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (_error?.contains('internet') == true ||
                _error?.contains('network') == true)
              Text(
                'Make sure you have an active internet connection',
                style: GoogleFonts.nunito(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                // Add a small delay to prevent rapid retries
                await Future.delayed(const Duration(milliseconds: 500));
                _fetchMassBookings();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Retry',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
        iconTheme: const IconThemeData(color: Colors.white),
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
              _trackInfo('build', 'Filter button pressed');
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.grey.shade50,
                                  ],
                                ),
                              ),
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
                                            fontWeight: FontWeight.w600,
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
                                      fontWeight: FontWeight.w600,
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.accent.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: AppColors.accent
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          '₦${mass.donationAmount.toStringAsFixed(2)}',
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.accent,
                                          ),
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
    IconData icon;

    switch (status) {
      case MassStatus.pending:
        color = AppColors.pending;
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case MassStatus.accepted:
        color = AppColors.success;
        text = 'Accepted';
        icon = Icons.check_circle;
        break;
      case MassStatus.rejected:
        color = AppColors.error;
        text = 'Rejected';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.nunito(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
