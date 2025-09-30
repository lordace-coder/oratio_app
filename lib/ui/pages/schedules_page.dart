import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
import 'package:oratio_app/ui/widgets/schedule_item.dart';
import 'package:pocketbase/pocketbase.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  bool loading = false;
  List<RecordModel> schedule = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getScheduleList();
    });
  }

  Future<void> getScheduleList() async {
    if (loading) return;
    setState(() {
      loading = true;
    });
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      final data = await pb
          .collection("schedule")
          .getList(sort: 'date', expand: "parish");
      schedule = data.items;
    } catch (e) {
      NotificationService.showError('Failed to load Schedules',
          duration: const Duration(seconds: 4));
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context, label: 'My Schedule'),
      body: loading
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              itemCount: schedule.length,
              itemBuilder: (context, index) => ScheduleItem(
                    title: schedule[index].getStringValue('title'),
                    dateTime:
                        DateTime.parse(schedule[index].getStringValue('date')),
                    location: schedule[index].getStringValue("location"),
                    parish: schedule[index]
                        .expand['parish']
                        ?.first
                        .getStringValue('name'),
                    category: schedule[index].getStringValue('type').isEmpty
                        ? 'Meeting'
                        : schedule[index].getStringValue('type'),
                    isCompleted: false,
                  )),
    );
  }
}
