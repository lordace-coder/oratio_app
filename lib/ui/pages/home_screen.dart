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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showBalance = false;
  final _pageController = PageController();
  String bal = '₦0.00';
  @override
  Widget build(BuildContext context) {
    context
        .read<PocketBaseServiceCubit>()
        .state
        .pb
        .collection('users')
        .authRefresh();
    final user = context.read<PocketBaseServiceCubit>().state.pb.authStore.model
        as RecordModel;
    bool isPriest = user.getBoolValue('priest');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.white,
            ],
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
              slivers: [
                // Modern App Bar

                // Balance Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Balance',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.white70,
                                      ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(
                                      () => showBalance = !showBalance),
                                  child: Icon(
                                    showBalance
                                        ? FontAwesomeIcons.eye
                                        : FontAwesomeIcons.eyeSlash,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(12),
                            FutureBuilder<String>(
                                initialData: bal,
                                future: getUserBalance(
                                  user.id,
                                  context
                                      .read<PocketBaseServiceCubit>()
                                      .state
                                      .pb,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    bal = snapshot.data!;
                                    return Text(
                                      showBalance
                                          ? '${snapshot.data}'
                                          : '• • • • • •',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                            const Gap(24),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    icon: FontAwesomeIcons.plus,
                                    label: 'Add Funds',
                                    onTap: () async {
                                      await collectPayment(context);
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: FontAwesomeIcons.clockRotateLeft,
                                    label: 'History',
                                    onTap: () => context
                                        .pushNamed(RouteNames.transactionsPage),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Gap(16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxHeight: 210), // Limit the height
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: [
                              _buildQuickAction(
                                icon: FontAwesomeIcons.book,
                                label: 'Book Mass',
                                onTap: () => context.pushNamed(RouteNames.mass),
                              ),
                              if (isPriest)
                                _buildQuickAction(
                                  icon: FontAwesomeIcons.desktop,
                                  label: 'Dashboard',
                                  onTap: () =>
                                      context.pushNamed(RouteNames.dashboard),
                                ),
                              _buildQuickAction(
                                icon: FontAwesomeIcons.church,
                                label: 'Join Parish',
                                onTap: () =>
                                    context.pushNamed(RouteNames.parishpage),
                              ),
                              _buildQuickAction(
                                icon: FontAwesomeIcons.handHoldingHeart,
                                label: 'Give',
                                onTap: () => showGiveOptions(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Features Grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Gap(16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1,
                          children: [
                            _buildFeatureCard(
                              icon: FontAwesomeIcons.peopleGroup,
                              label: 'Communities',
                              description: 'Connect with your faith community',
                              onTap: () =>
                                  context.pushNamed(RouteNames.communitypage),
                            ),
                            _buildFeatureCard(
                              icon: FontAwesomeIcons.clock,
                              label: 'Schedules',
                              description: 'View upcoming events',
                              onTap: () =>
                                  context.pushNamed(RouteNames.schedule),
                            ),
                            _buildFeatureCard(
                              icon: FontAwesomeIcons.bookOpen,
                              label: 'Daily Readings',
                              description: 'Scripture of the day',
                              onTap: () =>
                                  context.pushNamed(RouteNames.readingPage),
                            ),
                            _buildFeatureCard(
                              icon: FontAwesomeIcons.gears,
                              label: 'Settings',
                              description:
                                  'Configure the app to suit your needs',
                              onTap: () =>
                                  context.pushNamed(RouteNames.settingsPage),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent Transactions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
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
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const Gap(8),
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
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  children: state.transactions
                                      .map((transaction) => TransactionItem(
                                          transaction: transaction))
                                      .take(3)
                                      .toList(),
                                ),
                              );
                            } else {
                              return const Center(
                                child: Text('No transactions yet'),
                              );
                            }
                          },
                        )
                        // FutureBuilder(
                        //   builder: (context) {
                        //     return Card(
                        //       elevation: 0,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(16),
                        //         side: BorderSide(
                        //           color: Colors.grey.shade200,
                        //         ),
                        //       ),
                        //       child: const Column(
                        //         children: [
                        //           TransactionItem(),
                        //           TransactionItem(),
                        //           TransactionItem(),
                        //         ],
                        //       ),
                        //     );
                        //   }
                        // ),
                      ],
                    ),
                  ),
                ),
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
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const Gap(8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon),
          ),
          const Gap(8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon),
              ),
              const Gap(8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
