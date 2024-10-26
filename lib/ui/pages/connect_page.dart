import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/themes.dart';

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

  // Sample user data (same as before)
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Sarah Johnson',
      'username': '@sarahj',
      'followers': '1.2K',
      'isFollowing': false,
      'image': 'assets/avatar1.png'
    },
    {
      'name': 'Mike Chen',
      'username': '@mikechen',
      'followers': '892',
      'isFollowing': true,
      'image': 'assets/avatar2.png'
    },
    {
      'name': 'Sarah Johnson',
      'username': '@sarahj',
      'followers': '1.2K',
      'isFollowing': false,
      'image': 'assets/avatar1.png'
    },
    {
      'name': 'Mike Chen',
      'username': '@mikechen',
      'followers': '892',
      'isFollowing': true,
      'image': 'assets/avatar2.png'
    },
    {
      'name': 'Sarah Johnson',
      'username': '@sarahj',
      'followers': '1.2K',
      'isFollowing': false,
      'image': 'assets/avatar1.png'
    },
    {
      'name': 'Mike Chen',
      'username': '@mikechen',
      'followers': '892',
      'isFollowing': true,
      'image': 'assets/avatar2.png'
    },
    {
      'name': 'Sarah Johnson',
      'username': '@sarahj',
      'followers': '1.2K',
      'isFollowing': false,
      'image': 'assets/avatar1.png'
    },
    {
      'name': 'Mike Chen',
      'username': '@mikechen',
      'followers': '892',
      'isFollowing': true,
      'image': 'assets/avatar2.png'
    },
    {
      'name': 'Sarah Johnson',
      'username': '@sarahj',
      'followers': '1.2K',
      'isFollowing': false,
      'image': 'assets/avatar1.png'
    },
    {
      'name': 'Mike Chen',
      'username': '@mikechen',
      'followers': '892',
      'isFollowing': true,
      'image': 'assets/avatar2.png'
    },
  ];

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
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
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
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    children:
                        ['All', 'Following', 'Popular', 'New'].map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() => _selectedFilter = filter);
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

            // User List (same as before)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = _users[index];
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
                      name: user['name'],
                      username: user['username'],
                      followers: user['followers'],
                      isFollowing: user['isFollowing'],
                      onFollowTap: () {
                        setState(() {
                          user['isFollowing'] = !user['isFollowing'];
                        });
                      },
                    ),
                  );
                },
                childCount: _users.length,
              ),
            ),
          ],
        ),
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

class UserCard extends StatelessWidget {
  final String name;
  final String username;
  final String followers;
  final bool isFollowing;
  final VoidCallback onFollowTap;

  const UserCard({
    super.key,
    required this.name,
    required this.username,
    required this.followers,
    required this.isFollowing,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            name[0],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '$followers followers',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onFollowTap,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isFollowing ? Colors.grey[200] : Theme.of(context).primaryColor,
            foregroundColor: isFollowing ? Colors.black87 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(isFollowing ? 'Following' : 'Follow'),
        ),
      ),
    );
  }
}
