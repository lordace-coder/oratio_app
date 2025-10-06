import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/transactions_cubit/state.dart';
import 'package:oratio_app/bloc/transactions_cubit/transaction_cubit.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
import 'package:oratio_app/ui/widgets/home.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool showBalance = false;
  final _pageController = PageController();
  String bal = '₦0.00';

  void scrollToTop() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    Future.microtask(() async {
      await context
          .read<PocketBaseServiceCubit>()
          .state
          .pb
          .collection('users')
          .authRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final horizontalPadding = isSmallScreen ? 10.0 : 20.0;

    final pb = context.read<PocketBaseServiceCubit>().state.pb;
    if (!pb.authStore.isValid) {
      pb.authStore.clear();
      return const Center(
        child: Text('Session Expired. Please Sign In Again'),
      );
    }

    final user = context.read<PocketBaseServiceCubit>().state.pb.authStore.model
        as RecordModel;
    bool isPriest = user.getBoolValue('priest');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.15),
              Colors.white,
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator.adaptive(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              setState(() {});
              await context.read<TransactionCubit>().fetchTransactions();
            },
            child: CustomScrollView(
              controller: _pageController,
              slivers: [
                // Spiritual Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 15, horizontalPadding, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menu',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Gap(4),
                      ],
                    ),
                  ),
                ),

                // Sacred Actions Grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 24, horizontalPadding, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: screenSize.width < 300 ? 2 : 4,
                          mainAxisSpacing: isSmallScreen ? 12 : 16,
                          crossAxisSpacing: isSmallScreen ? 12 : 16,
                          childAspectRatio: isSmallScreen ? 0.9 : 1.0,
                          children: [
                            _buildSacredAction(
                              icon: FontAwesomeIcons.book,
                              label: 'Book Mass',
                              onTap: () => context.pushNamed(RouteNames.mass),
                            ),
                            if (isPriest)
                              _buildSacredAction(
                                icon: FontAwesomeIcons.desktop,
                                label: 'Dashboard',
                                onTap: () async => {
                                  if (await canLaunchUrl(Uri.parse(
                                      "https://cathsapp.ng/priest?token=${pb.authStore.token}")))
                                    {
                                      launchUrl(Uri.parse(
                                          "https://cathsapp.ng/priest?token=${pb.authStore.token}"))
                                    }
                                },
                              ),
                            if (isPriest)
                              _buildSacredAction(
                                  icon: FontAwesomeIcons.ellipsisVertical,
                                  label: 'Do More',
                                  onTap: () {
                                    showDoMoreOptions(context,
                                        showOfferingOption: true);
                                  }),
                            if (!isPriest)
                              _buildSacredAction(
                                  icon: FontAwesomeIcons.ellipsisVertical,
                                  label: 'Do More',
                                  onTap: () {
                                    // TODO SHOW DO MORE
                                    //  options which include retreat,counselling,and appointment with spiritual director
                                    showDoMoreOptions(
                                      context,
                                    );
                                  }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Ministry Features
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ministry & Fellowship',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Gap(16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: screenSize.width < 600 ? 2 : 3,
                          mainAxisSpacing: isSmallScreen ? 8 : 10,
                          crossAxisSpacing: isSmallScreen ? 8 : 10,
                          childAspectRatio: screenSize.width < 360 ? 1.2 : 1.3,
                          children: [
                            _buildMinistryCard(
                              icon: FontAwesomeIcons.clock,
                              label: 'Schedules',
                              description: 'View liturgical schedules',
                              onTap: () =>
                                  context.pushNamed(RouteNames.schedule),
                            ),
                            _buildMinistryCard(
                              icon: FontAwesomeIcons.bookOpen,
                              label: 'Daily Word',
                              description: 'Scripture readings & reflections',
                              onTap: () =>
                                  context.pushNamed(RouteNames.readingPage),
                            ),
                            _buildMinistryCard(
                              icon: FontAwesomeIcons.gears,
                              label: 'Preferences',
                              description: 'Customize your spiritual journey',
                              onTap: () =>
                                  context.pushNamed(RouteNames.settingsPage),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Offerings History
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pending Payments',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextButton(
                              onPressed: () => context
                                  .pushNamed(RouteNames.transactionsPage),
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        BlocConsumer<TransactionCubit, TransactionState>(
                          listener: (context, state) {},
                          builder: (context, state) {
                            if (state.status == TransactionStatus.initial) {
                              context
                                  .read<TransactionCubit>()
                                  .fetchTransactions();
                            }
                            if (state.status == TransactionStatus.loading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state.status ==
                                TransactionStatus.success) {
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  children: state.disputes
                                      .map((transaction) => TransactionItem(
                                          transaction: transaction))
                                      .take(3)
                                      .toList(),
                                ),
                              );
                            } else {
                              return Center(
                                child: Text(
                                  'Begin your giving journey',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.95),
        foregroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isSmallScreen ? 14 : 16),
          Gap(isSmallScreen ? 4 : 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSacredAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final containerPadding = isSmallScreen ? 8.0 : 12.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isSmallScreen ? 48.0 : 56.0,
            height: isSmallScreen ? 48.0 : 56.0,
            padding: EdgeInsets.all(containerPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: iconSize,
            ),
          ),
          const Gap(4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinistryCard({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              Gap(isSmallScreen ? 6 : 8),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Gap(isSmallScreen ? 2 : 3),
              Flexible(
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.2,
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
