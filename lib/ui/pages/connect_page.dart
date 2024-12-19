import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';
  bool _isScrolled = false;
  List<RecordModel>? _users;
  int page = 1;
  String? search;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUsers();
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Future getUsers({String? filter}) async {
    if (filter != null) setState(() => _selectedFilter = filter);
    if (_selectedFilter == 'All') {
      final q = search != null
          ? '(username ~ "$search" || email ~ "$search" || first_name ~ "$search" || last_name ~ "$search")'
          : 'priest = ${filter == 'Priest'}';
      try {
        final newData = await listUsers(context, page: page, filter: q);
        _users = [...newData];
        setState(() {});
      } catch (e) {
        print(e);
      }
      return;
    }

    final q = search != null
        ? '(username ~ "$search" || email ~ "$search" || first_name ~ "$search" || last_name ~ "$search") && priest = ${_selectedFilter == 'Priest'}'
        : 'priest = ${filter == 'Priest'}';
    try {
      final newData = await listUsers(context, page: page, filter: q);
      _users = [...newData];
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void handleFollowUser(String id) {
    try {
      final user = _users!.firstWhere((test) => test.id == id);
      setState(() {
        user.data['following'] = true;
      });
      followUser(context, targetUserId: id);
    } catch (e) {
      // show eror here
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            _onScroll();
          }
          return false;
        },
        child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Enhanced App Bar
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                stretch: true,
                leading: IconButton(
                  icon: const Icon(FontAwesomeIcons.chevronLeft),
                  // Cupertino style back button
                  color: Colors.white,
                  onPressed: () => context.pop(),
                ),
                backgroundColor: AppColors.primary,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient background
                      Container(
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
                      ),
                      // Decorative circles
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Hero(
                          tag: 'finduser',
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Positioned(
                        bottom: 60,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_alt_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Connect',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Find and follow other users',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Search Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverSearchAppBar(
                  minHeight: 80,
                  maxHeight: 80,
                  child: Container(
                    color: Colors.grey[50],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Hero(
                      tag: 'searchBar',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (query) {
                              search = query;
                              getUsers();
                            },
                            decoration: InputDecoration(
                              hintText: 'Search users...',
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverFilterDelegate(
                  minHeight: 60,
                  maxHeight: 60,
                  child: Container(
                    color: Colors.grey[50],
                    padding: const EdgeInsets.only(left: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['All', 'Priest', 'Users'].map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              getUsers(filter: filter);
                            },
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: _selectedFilter == filter
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            elevation: 0,
                            pressElevation: 2,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              if (_users != null)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = _users![index];
                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: UserCard(
                          id: user.id,
                          name: getFullName(user),
                          username: user.getStringValue('username'),
                          followers:
                              user.getListValue('followers').length.toString(),
                          isFollowing: isFollowing(
                              context
                                  .read<PocketBaseServiceCubit>()
                                  .state
                                  .pb
                                  .authStore
                                  .model
                                  .id,
                              user.getListValue('followers')),
                          onFollowTap: () {
                            handleFollowUser(user.id);
                          },
                        ),
                      );
                    },
                    childCount: _users!.length,
                  ),
                ),
            ]),
      ),
    );
  }
}

// Custom delegate for search bar
class _SliverSearchAppBar extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverSearchAppBar({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverSearchAppBar oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

// Custom delegate for filter chips
class _SliverFilterDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverFilterDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverFilterDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class UserCard extends StatefulWidget {
  final String name;
  final String username;
  final String followers;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final String id;
  const UserCard({
    super.key,
    required this.name,
    required this.username,
    required this.followers,
    required this.isFollowing,
    required this.onFollowTap,
    required this.id,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool? following;

  void followUser() {
    setState(() {
      following = true;
    });
    widget.onFollowTap.call();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    following ??= widget.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(RouteNames.profilepagevisitor,
            pathParameters: {'id': widget.id});
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            child: Text(
              widget.name[0],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            widget.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.username,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.followers} followers',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: followUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: following!
                  ? Colors.grey[200]
                  : Theme.of(context).primaryColor,
              foregroundColor: following! ? Colors.black87 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(following! ? 'Following' : 'Follow'),
          ),
        ),
      ),
    );
  }
}
