import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/bloc/priest_bloc/event.dart';
import 'package:oratio_app/bloc/priest_bloc/priest_bloc.dart';
import 'package:oratio_app/bloc/priest_bloc/state.dart';
import 'package:oratio_app/bloc/transactions_cubit/state.dart';
import 'package:oratio_app/bloc/transactions_cubit/transaction_cubit.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/home.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:pdf/widgets.dart' as pw;

class ParishTransactionsPage extends StatefulWidget {
  const ParishTransactionsPage({super.key});
  @override
  State<ParishTransactionsPage> createState() => _ParishTransactionsPageState();
}

class _ParishTransactionsPageState extends State<ParishTransactionsPage> {
  final ScrollController _controller = ScrollController();
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  _onScroll() {
    if (_controller.offset >= _controller.position.maxScrollExtent) {
      print('load more transactions');
    }
  }

  Future<void> _refreshTransactions() async {
    context.read<PriestBloc>().add(FetchTransactionsEvent(ctx: context));
    await Future.delayed(Durations.extralong4);
  }

  Future<void> _downloadTransactions() async {
    try {
      final transactions = context.read<TransactionCubit>().state.transactions;
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Transactions for October 2024',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                ...transactions.map((transaction) {
                  return pw.Text(
                    '${transaction.title}: \$${transaction.amount} (${transaction.type.toString().split('.').last})',
                    style: const pw.TextStyle(fontSize: 16),
                  );
                }),
              ],
            );
          },
        ),
      );

      final directory = await pathProvider.getExternalStorageDirectory();
      final file = File('${directory?.path}/transactions_october_2024.pdf');
      await file.writeAsBytes(await pdf.save());

      _showDownloadModal(file.path);
    } catch (e) {
      NotificationService.showError("Failed to save transactions");
    }
  }

  void _showDownloadModal(String filePath) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Transactions Saved',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              const Text(
                'The transactions have been saved as a PDF. You can now share or open the file.',
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      OpenFilex.open(filePath);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
       
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTransactions();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _downloadTransactions,
            icon: const Icon(
              Icons.download_rounded,
              size: 20,
              color: Colors.white,
            ),
            label: const Text(
              'Download',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshTransactions,
          child: BlocBuilder<PriestBloc, PriestState>(
            builder: (context, state) {
              if (state.transactions.isEmpty) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      child: _EmptyTransactionsState(
                        onRefresh: _refreshTransactions,
                      ),
                    ),
                  ],
                );
              }
              final data = state.transactions
                  .map(
                    (item) => Transaction(
                        created: DateTime.parse(item.created),
                        id: item.id,
                        read: item.getBoolValue('read'),
                        successful: item.getBoolValue('succesfull'),
                        title: item.getStringValue('title'),
                        transaction: item.getStringValue('transaction'),
                        type: Transaction.getTransactionType(
                            item.getStringValue('type')),
                        amount: item.getIntValue('amount').toDouble()),
                  )
                  .toList();

              final moneyIn = data
                  .where((transaction) =>
                      transaction.type == TransactionType.recieved)
                  .fold(0.0,
                      (sum, transaction) => sum + (transaction.amount ?? 0.0));

              final moneyOut = data
                  .where(
                      (transaction) => transaction.type == TransactionType.sent)
                  .fold(0.0,
                      (sum, transaction) => sum + (transaction.amount ?? 0.0));

              return ListView(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMMM yyyy').format(DateTime.now()),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const Gap(6),
                                  Text(
                                    'This Month',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(20),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                label: 'Money In',
                                amount: currencyFormatter.format(moneyIn),
                                icon: Icons.arrow_downward_rounded,
                                iconColor: Colors.green[700]!,
                                backgroundColor: Colors.green[50]!,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: _SummaryCard(
                                label: 'Money Out',
                                amount: currencyFormatter.format(moneyOut),
                                icon: Icons.arrow_upward_rounded,
                                iconColor: Colors.red[700]!,
                                backgroundColor: Colors.red[50]!,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Gap(12),
                  ...data.map((transaction) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: TransactionItem(transaction: transaction),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const Gap(12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const Gap(4),
          Text(
            '\$$amount',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyTransactionsState({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const Gap(24),
        Text(
          'No Transactions Yet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const Gap(12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Your parish transactions will appear here once they are recorded.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ),
        const Gap(32),
        TextButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
