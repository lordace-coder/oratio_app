import 'dart:developer';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
import 'package:oratio_app/ui/widgets/home.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final ScrollController _controller = ScrollController();

  _onScroll() {
    if (_controller.offset >= _controller.position.maxScrollExtent) {
      print('load more transactions');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context,
          label: 'Transactions',
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          actions: [
            GestureDetector(
              onTap: () async {
                // TODO handle save data to selected directory
                String? savePath;
                savePath = await FilesystemPicker.open(
                    context: context,
                    rootDirectory:
                        (await pathProvider.getExternalStorageDirectories())
                            ?.first
                            .parent);
              },
              child: Text(
                'Download',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
            const Gap(10),
          ]),
      body: SafeArea(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Oct'),
                Gap(10),
                Row(
                  children: [
                    Text('in: \$30,000'),
                    Gap(10),
                    Text('out: \$30,000'),
                  ],
                )
              ],
            ),
          ),
          const Gap(10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView.builder(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: 29,
                  itemBuilder: (context, index) {
                    return const TransactionItem();
                  }),
            ),
          )
        ],
      )),
    );
  }
}
