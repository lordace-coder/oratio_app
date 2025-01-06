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
    final pb = context.read<PocketBaseServiceCubit>().state.pb;
    if (!pb.authStore.isValid) {
      pb.authStore.clear();
      return const Center(
        child: Text('Session Expired. Please Sign In Again'),
      );
    }

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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      10,
                      15,
                      5,
                      MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet',
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
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03,
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Theme.of(context).primaryColor,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.04,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Wallet Balance',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => showBalance = !showBalance),
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        showBalance
                                            ? FontAwesomeIcons.eye
                                            : FontAwesomeIcons.eyeSlash,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(16),
                              FutureBuilder<String>(
                                  initialData: bal,
                                  future: getUserBalance(
                                      user.id,
                                      context
                                          .read<PocketBaseServiceCubit>()
                                          .state
                                          .pb),
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
                                    }
                                    return Container();
                                  }),
                              const Gap(24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: FontAwesomeIcons.plus,
                                      label: 'Add Offering',
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
                                      label: 'Transaction History',
                                      onTap: () => context.pushNamed(
                                          RouteNames.transactionsPage),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.05,
                      24,
                      MediaQuery.of(context).size.width * 0.05,
                      10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Services',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Gap(16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 6 : 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
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
                                onTap: () =>
                                    context.pushNamed(RouteNames.dashboard),
                              ),
                            _buildSacredAction(
                              icon: FontAwesomeIcons.church,
                              label: 'Join Parish',
                              onTap: () =>
                                  context.pushNamed(RouteNames.parishpage),
                            ),
                            _buildSacredAction(
                              icon: FontAwesomeIcons.handHoldingHeart,
                              label: 'Give',
                              onTap: () => showGiveOptions(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.05,
                    ),
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
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.1,
                          children: [
                            _buildMinistryCard(
                              icon: FontAwesomeIcons.peopleGroup,
                              label: 'Communities',
                              description: 'Connect with fellow believers',
                              onTap: () =>
                                  context.pushNamed(RouteNames.communitypage),
                            ),
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
                  Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Offerings',
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
                                  children: state.transactions
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
                ],
              ),
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
        backgroundColor: Colors.white.withOpacity(0.95),
        foregroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const Gap(8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
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
          padding: const EdgeInsets.all(10.0),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const Gap(12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const Gap(4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
