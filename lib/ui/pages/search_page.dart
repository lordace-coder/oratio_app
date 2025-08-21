import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/ui/pages/pages.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = false;
  List<RecordModel> _searchResults = [];

  late PocketBase pb;

  @override
  void initState() {
    super.initState();
    pb = getPocketBaseFromContext(context);
    _loadDefaultData();
  }

  void _loadDefaultData() async {
    setState(() {
      _isLoading = true;
    });

    final currentUser = pb.authStore.model as RecordModel;
    final result = await pb
        .collection('users')
        .getList(filter: "followers ~ '${currentUser.id}'");

    setState(() {
      _searchResults = result.items;
      _isLoading = false;
    });
  }

  void _handleSearch() async {
    final query = _searchController.text;
    setState(() {
      _isSearching = query.isNotEmpty;
      _isLoading = true;
    });

    if (_isSearching) {
      final currentUser = pb.authStore.model as RecordModel;
      final result = await pb.collection('users').getList(
          filter:
              "followers ~ '${currentUser.id}' &&  (username ~ '$query' || first_name ~ '$query' || last_name ~ '$query' || phone_number ~ '$query')");

      setState(() {
        _searchResults = result.items
            .where((item) =>
                currentUser.getListValue('followers').contains(item.id))
            .toList();
        _isLoading = false;
      });
    } else {
      _loadDefaultData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Search Friends',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, color: Colors.black),
          onPressed: () {
            context.pop();
          },
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                cursorColor: AppColors.primary,
                textInputAction: TextInputAction.search,
                controller: _searchController,
                onSubmitted: (_) => _handleSearch(),
                decoration: InputDecoration(
                  hintText: 'Search by name or username',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _handleSearch,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[300],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            return ChatCard(
                              id: user.id,
                              name:
                                  '${user.getStringValue('first_name')} ${user.getStringValue('last_name')}',
                              username: user.getStringValue('username'),
                              followers: user
                                  .getListValue('followers')
                                  .length
                                  .toString(),
                              profilePicture: getAvatarUrl(context,
                                  record: user,
                                  fileName: user.getStringValue('avatar')),
                              onChat: () {
                                // Implement follow functionality
                                context.pushNamed(RouteNames.chatDetailPage,
                                    pathParameters: {
                                      'profile': Profile(
                                        community: [],
                                        contact:
                                            user.getStringValue('phone_number'),
                                        parish: [],
                                        user: user,
                                        userId: user.id,
                                      ).toJsonString()
                                    });
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final String name;
  final String username;
  final String followers;
  final VoidCallback onChat;
  final String id;
  final String? profilePicture;

  const ChatCard({
    super.key,
    this.profilePicture,
    required this.name,
    required this.username,
    required this.followers,
    required this.onChat,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(RouteNames.profilepagevisitor,
            pathParameters: {'id': id});
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(10),
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  profilePicture != null && profilePicture!.isNotEmpty
                      ? CachedNetworkImageProvider(profilePicture!)
                      : null,
              child: profilePicture == null
                  ? Text(
                      name[0],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
            ),
            ElevatedButton(
              onPressed: onChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Chat"),
            ),
          ],
        ),
      ),
    );
  }
}
