import 'package:flutter/material.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';
import 'package:oratio_app/ui/widgets/live_streams.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';

class FeedsListScreen extends StatefulWidget {
  const FeedsListScreen({super.key});

  @override
  _FeedsListScreenState createState() => _FeedsListScreenState();
}

class _FeedsListScreenState extends State<FeedsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.primary,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        Theme.of(context).primaryColor,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        context.pushNamed(RouteNames.profile),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 20,
                                        child: Icon(FontAwesomeIcons.user),
                                      ),
                                    ),
                                  ),
                                  const Gap(12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back,',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Colors.white,
                                            ),
                                      ),
                                      Text(
                                        'Chibuike',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  buildIconButton(
                                    icon: FontAwesomeIcons.magnifyingGlass,
                                    onTap: () {
                                      context.pushNamed(RouteNames.connect);
                                    },
                                  ),
                                  const Gap(8),
                                  buildIconButton(
                                    icon: FontAwesomeIcons.bell,
                                    onTap: () => context
                                        .pushNamed(RouteNames.notifications),
                                    hasNotification: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Community Posts'),
                  Tab(text: 'Prayer Requests'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Community Posts Tab
            ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: 11,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: buildStorySection(context),
                  );
                }
                return const CommunityPostCard();
              },
            ),

            // Prayer Requests Tab
            ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: 10,
              itemBuilder: (context, index) => const PrayerRequestCard(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show post creation dialog
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                'SC',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: const Text(
              'St. Catherine\'s Prayer Group',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('2 hours ago'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Join us for the Novena to Our Lady of Perpetual Help every Wednesday at 6:00 PM.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          // Post Image
          Container(
            margin: const EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Center(
              child: Icon(
                Icons.church,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          // Post Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _PostAction(
                  icon: Icons.favorite_border,
                  label: '24',
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                _PostAction(
                  icon: Icons.comment_outlined,
                  label: '5',
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                _PostAction(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrayerRequestCard extends StatelessWidget {
  const PrayerRequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prayer Request Header
          ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: const Text(
                'JD',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: const Text(
              'John Doe',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('1 hour ago', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 8),
                Icon(Icons.public, size: 14, color: Colors.grey[600]),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(child: Text('Report')),
                const PopupMenuItem(child: Text('Share')),
              ],
            ),
          ),
          // Prayer Request Content
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Urgent Prayer Request',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please pray for my mother who is undergoing surgery tomorrow morning. 🙏',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // Prayer Actions
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _PrayerAction(
                  icon: Icons.favorite_border,
                  label: 'Praying (42)',
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _PrayerAction(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PostAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _PrayerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrayerAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.5)),
        ),
      ),
    );
  }
}
