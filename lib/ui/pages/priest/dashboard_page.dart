import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/bloc/priest_bloc/event.dart';
import 'package:oratio_app/bloc/priest_bloc/priest_bloc.dart';
import 'package:oratio_app/bloc/priest_bloc/state.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/bloc/transactions_cubit/state.dart';
import 'package:oratio_app/bloc/transactions_cubit/transaction_cubit.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/networkProvider/paystack_payment.dart';
import 'package:oratio_app/ui/bright/pages/withdrawal_modal.dart';
import 'package:oratio_app/ui/pages/priest/live_page.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/home.dart';
import 'package:pocketbase/pocketbase.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool showBalance = false;
  List _availableBanks = [];
  RecordModel? myParish;

  void showComingSoon() {
    NotificationService.showInfo("Coming soon", duration: Durations.extralong4);
  }

  Future<void> loadChurchForPriest() async {
    final pb = context.read<PocketBaseServiceCubit>().state.pb;
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

  void handleGetBankList() async {
    try {
      if (_availableBanks.isEmpty) {
        final res = await getBankList();

        setState(() {
          _availableBanks = res;
        });
      }
    } catch (e) {
      NotificationService.showError(
        'Failed to load bank list',
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadChurchForPriest();
      handleGetBankList();
    });
  }

  @override
  Widget build(BuildContext context) {
    handleGetBankList();

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 243, 243, 243),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, myParish?.getStringValue('name') ?? ''),
              Expanded(
                child: RefreshIndicator.adaptive(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await loadChurchForPriest();
                    context
                        .read<PriestBloc>()
                        .add(FetchTransactionsEvent(ctx: context));
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      FadeInDown(child: _buildBalanceCard()),
                      const Gap(20),
                      FadeInLeft(child: _buildQuickActions(context)),
                      const Gap(20),
                      FadeInRight(child: _buildMainGrid(context)),
                      const Gap(20),
                      FadeInUp(child: _buildRecentActivities(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String parishName) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(FontAwesomeIcons.arrowLeft)),
          Text(
            parishName.isNotEmpty ? '$parishName\'s Dashboard' : 'Dashboard',
            style: const TextStyle(
              fontSize: 24,
              // color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  openWhatsApp(
                      phoneNumber: '+2347032096095',
                      message: 'Im looking for customer support');
                },
                child: const Row(
                  children: [
                    Icon(FontAwesomeIcons.userNinja, size: 16),
                    Gap(8),
                    Text('Customer Support'),
                  ],
                ),
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.question, size: 16),
                    Gap(8),
                    Text('Get Help'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    RecordModel? parish;
    if (context.watch<ProfileDataCubit>().state is ProfileDataLoaded) {
      parish = (context.read<ProfileDataCubit>().state as ProfileDataLoaded)
          .profile
          .parishLeading;
    }
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.deepPurple.shade900],
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Available Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            showBalance
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white60,
                            size: 16,
                          ),
                          onPressed: () =>
                              setState(() => showBalance = !showBalance),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () =>
                          context.pushNamed(RouteNames.transactionsPage),
                      child: const Text(
                        'View Transactions',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      showBalance
                          ? '₦${parish != null ? parish.getDoubleValue('wallet') : "0.0"}'
                          : '* * * * * *',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => WithdrawalModal(
                            banks: _availableBanks,
                            parish: parish!,
                          ),
                        );
                      },
                      icon: const Icon(FontAwesomeIcons.moneyBillTransfer,
                          size: 16),
                      label: const Text('Withdraw'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final profile = context.read<ProfileDataCubit>().state;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  icon: FontAwesomeIcons.book,
                  label: 'Mass\nRequests',
                  onTap: () {
                    context.pushNamed(RouteNames.massRequests);
                  },
                  color: Colors.blue,
                ),
                _buildQuickActionButton(
                  icon: FontAwesomeIcons.church,
                  label: 'Create\nCommunity',
                  onTap: () {
                    // check if profile is loaded
                    if (profile is ProfileDataLoaded) {
                      if (profile.profile.parishLeading != null) {
                        context.pushNamed(RouteNames.createCommunityPage);
                      } else {
                        NotificationService.showWarning(
                            'Priest isnt leading any parish currently, if this is an issue then refresh');
                      }
                    }
                  },
                  color: Colors.green,
                ),
                _buildQuickActionButton(
                  icon: FontAwesomeIcons.clock,
                  label: 'Create\nEvent',
                  onTap: () {
                    context.pushNamed(RouteNames.createEvent);
                  },
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMainGrid(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parish Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
              children: [
                _buildServiceButton(
                  icon: FontAwesomeIcons.userGroup,
                  label: 'Seeking\nSouls',
                  onTap: showComingSoon,
                  color: Colors.purple,
                ),
                _buildServiceButton(
                  icon: FontAwesomeIcons.cashRegister,
                  label: 'Offerings',
                  onTap: () {},
                  color: Colors.green,
                ),
                _buildServiceButton(
                  icon: FontAwesomeIcons.qrcode,
                  label: 'Generate\nQR',
                  onTap: showComingSoon,
                  color: Colors.blue,
                ),
                _buildServiceButton(
                  icon: FontAwesomeIcons.readme,
                  label: 'Go Live',
                  onTap: () {
                    if (myParish!.getBoolValue('canGoLive')) {
                      // handle going live
                      Navigator.of(context).push(LiveMassPage.route(
                        parishId: myParish!.id,
                        isPriest: true,
                      ));
                    } else {
                      NotificationService.showWarning(
                          'This Service is not available for your parish');
                    }
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const Gap(8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.pushNamed(RouteNames.parishTransactions),
                  child: const Text('See All'),
                ),
              ],
            ),
            const Gap(16),

            BlocConsumer<PriestBloc, PriestState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state.transactions.isEmpty) {
                  context
                      .read<PriestBloc>()
                      .add(FetchTransactionsEvent(ctx: context));
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    ...state.transactions.map(
                      (item) => TransactionItem(
                        transaction: Transaction(
                            created: DateTime.parse(item.created),
                            id: item.id,
                            read: item.getBoolValue('read'),
                            successful: item.getBoolValue('succesfull'),
                            title: item.getStringValue('title'),
                            transaction: item.getStringValue('transaction'),
                            type: Transaction.getTransactionType(
                                item.getStringValue('type')),
                            amount: item.getIntValue('amount').toDouble()),
                      ),
                    )
                  ],
                );
              },
            )
            // const TransactionItem(),
            // const TransactionItem(),
            // const TransactionItem(),
            // const TransactionItem(),
          ],
        ),
      ),
    );
  }
}
