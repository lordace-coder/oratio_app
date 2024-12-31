import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart'; // Add this import

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  late PocketBase pb;

  @override
  void initState() {
    super.initState();
    pb = getPocketBaseFromContext(context);
  }

  void _handleSearch(String query) async {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (_isSearching) {
      final currentUser = pb.authStore.model as RecordModel;
      final result = await pb.collection('users').getList(
            filter: 'name ~ "$query" || username ~ "$query"',
          );

      setState(() {
        _searchResults = result.items
            .where((item) =>
                item.getListValue('followers').contains(currentUser.id) &&
                currentUser.getListValue('followers').contains(item.id))
            .map((item) => {
                  'id': item.id,
                  'name': item.data['first_name'],
                  'username': item.data['username'],
                  'followers': (item.data as RecordModel)
                      .getListValue('followers')
                      .length
                      .toString(),
                })
            .toList();
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.chevronLeft,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context.pop();
                        },
                      ),
                      const SizedBox(width: 16),
                      const Hero(
                        tag: 'search',
                        child: Text(
                          'Search Friends',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    cursorColor: AppColors.primary,
                    controller: _searchController,
                    onChanged: _handleSearch,
                    decoration: InputDecoration(
                      hintText: 'Search by name or username',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isSearching
                  ? ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return ChatCard(
                          id: user['id'],
                          name: user['name'],
                          username: user['username'],
                          followers: user['followers'],
                          onFollowTap: () {
                            // Implement follow functionality
                            print('Following ${user['name']}');
                          },
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search for friends',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatCard extends StatefulWidget {
  final String name;
  final String username;
  final String followers;

  final VoidCallback onFollowTap;
  final String id;
  final String? profilePicture;

  const ChatCard({
    super.key,
    this.profilePicture,
    required this.name,
    required this.username,
    required this.followers,
    required this.onFollowTap,
    required this.id,
  });

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
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
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(RouteNames.profilepagevisitor,
            pathParameters: {'id': widget.id});
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
              backgroundImage: widget.profilePicture != null
                  ? NetworkImage(widget.profilePicture!)
                  : null,
              child: widget.profilePicture == null
                  ? Text(
                      widget.name[0],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null),
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
            child: const Text('Chat'),
          ),
        ),
      ),
    );
  }
}
