import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:oratio_app/bloc/transactions_cubit/state.dart';
import 'package:oratio_app/bloc/transactions_cubit/transaction_cubit.dart';
import 'package:oratio_app/ui/themes.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});
  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with TickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  final List<String> _tabs = ['Payment Disputes', 'Mass Bookings', 'Retreats'];

  _onScroll() {
    if (_controller.offset >= _controller.position.maxScrollExtent) {
      print('load more transactions');
    }
  }

  Future<void> _refreshTransactions() async {
    await context.read<TransactionCubit>().fetchTransactions();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _tabController = TabController(length: _tabs.length, vsync: this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTransactions();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: NestedScrollView(
          controller: _controller,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(context),
              _buildSliverTabBar(),
            ];
          },
          body: RefreshIndicator(
            onRefresh: _refreshTransactions,
            child: BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                if (state.status == TransactionStatus.loading) {
                  return _buildLoadingState();
                } else if (state.status == TransactionStatus.failure) {
                  return _buildErrorState(state.error ?? 'Unknown error');
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      RefreshIndicator(
                        onRefresh: _refreshTransactions,
                        child: PaymentDisputesList(disputes: state.disputes),
                      ),
                      RefreshIndicator(
                        onRefresh: _refreshTransactions,
                        child: MassBookingsList(bookings: state.booking),
                      ),
                      RefreshIndicator(
                        onRefresh: _refreshTransactions,
                        child: RetreatsList(retreats: state.retreat),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: false,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const Gap(16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction History',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          Text(
                            'Track your financial activities',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 3,
              color: AppColors.primary,
            ),
            insets: const EdgeInsets.symmetric(horizontal: 16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const Gap(24),
          Text(
            'Loading your transactions...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 32,
            ),
          ),
          const Gap(20),
          Text(
            'Unable to load transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const Gap(8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Gap(24),
          ElevatedButton.icon(
            onPressed: _refreshTransactions,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Payment Disputes List Component
class PaymentDisputesList extends StatelessWidget {
  final List<PaymentDispute> disputes;
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  PaymentDisputesList({super.key, required this.disputes});

  @override
  Widget build(BuildContext context) {
    if (disputes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.gavel_outlined,
        title: 'No payment disputes',
        description: 'Your payment dispute history will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: disputes.length,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) {
        final dispute = disputes[index];
        return PaymentDisputeCard(dispute: dispute);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.grey[400],
                size: 48,
              ),
            ),
            const Gap(20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const Gap(8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mass Bookings List Component
class MassBookingsList extends StatelessWidget {
  final List<MassBooking> bookings;
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  MassBookingsList({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.church_outlined,
        title: 'No mass bookings',
        description:
            'Your mass booking history will appear here once you make your first booking.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return MassBookingCard(booking: booking);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.grey[400],
                size: 48,
              ),
            ),
            const Gap(20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const Gap(8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Retreats List Component
class RetreatsList extends StatelessWidget {
  final List<Retreat> retreats;
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  RetreatsList({super.key, required this.retreats});

  @override
  Widget build(BuildContext context) {
    if (retreats.isEmpty) {
      return _buildEmptyState(
        icon: Icons.nature_people_outlined,
        title: 'No retreat bookings',
        description:
            'Your retreat booking history will appear here once you book your first retreat.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: retreats.length,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) {
        final retreat = retreats[index];
        return RetreatCard(retreat: retreat);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.grey[400],
                size: 48,
              ),
            ),
            const Gap(20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const Gap(8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Individual Card Components
class PaymentDisputeCard extends StatelessWidget {
  final PaymentDispute dispute;
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  PaymentDisputeCard({super.key, required this.dispute});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: dispute.confirmed
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    dispute.confirmed ? Icons.check_circle : Icons.pending,
                    color: dispute.confirmed
                        ? Colors.green[600]
                        : Colors.orange[600],
                    size: 20,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Dispute',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        dispute.confirmed ? 'Confirmed' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: dispute.confirmed
                              ? Colors.green[600]
                              : Colors.orange[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₦${currencyFormatter.format(dispute.amount)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Bank', dispute.bank_name),
                ),
                Expanded(
                  child: _buildInfoItem('Account', dispute.account_name),
                ),
              ],
            ),
            const Gap(8),
            _buildInfoItem('Reference', dispute.transaction_ref),
            const Gap(12),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(dispute.created),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class MassBookingCard extends StatelessWidget {
  final MassBooking booking;

  const MassBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: booking.confirmed
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.church,
                    color: booking.confirmed
                        ? Colors.green[600]
                        : Colors.orange[600],
                    size: 20,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mass Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        booking.confirmed ? 'Confirmed' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: booking.confirmed
                              ? Colors.green[600]
                              : Colors.orange[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (booking.anonymous)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Anonymous',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(16),
            Text(
              "${booking.intention}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                      'Start Time',
                      DateFormat('MMM dd, yyyy\nhh:mm a')
                          .format(booking.startTime)),
                ),
                if (booking.endTime != null)
                  Expanded(
                    child: _buildInfoItem(
                        'End Time',
                        DateFormat('MMM dd, yyyy\nhh:mm a')
                            .format(booking.endTime!)),
                  ),
              ],
            ),
            if (booking.parish != null) ...[
              const Gap(8),
              _buildInfoItem(
                  'Parish', booking.parish!.data['name'] ?? 'Unknown Parish'),
            ],
            const Gap(12),
            Text(
              DateFormat('Created: MMM dd, yyyy • hh:mm a')
                  .format(booking.created),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class RetreatCard extends StatelessWidget {
  final Retreat retreat;

  const RetreatCard({super.key, required this.retreat});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.nature_people,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Retreat Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (retreat.description != null) ...[
              const Gap(16),
              Text(
                retreat.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
            const Gap(12),
            if (retreat.startTime != null && retreat.endTime != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                        'Start Date',
                        DateFormat('MMM dd, yyyy\nhh:mm a')
                            .format(retreat.startTime!)),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                        'End Date',
                        DateFormat('MMM dd, yyyy\nhh:mm a')
                            .format(retreat.endTime!)),
                  ),
                ],
              ),
              const Gap(8),
              if (retreat.startTime != null && retreat.endTime != null)
                _buildInfoItem('Duration',
                    '${retreat.endTime!.difference(retreat.startTime!).inDays + 1} days'),
            ],
            const Gap(12),
            Text(
              DateFormat('Booked: MMM dd, yyyy • hh:mm a')
                  .format(retreat.created),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
