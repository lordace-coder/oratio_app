import 'package:ace_toast/ace_toast.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/community.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/ui/pages/search/search_items.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();

  List<String> _recentSearches = [];
  Map<String, dynamic>? _searchData;
  bool _isLoading = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  // Save recent searches to SharedPreferences
  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList('recent_searches') ?? [];

    // Remove if already exists to avoid duplicates
    searches.remove(query);
    // Add to beginning
    searches.insert(0, query);
    // Keep only last 10 searches
    if (searches.length > 10) {
      searches = searches.sublist(0, 10);
    }

    await prefs.setStringList('recent_searches', searches);
    setState(() {
      _recentSearches = searches;
    });
  }

  // Clear all recent searches
  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() {
      _recentSearches = [];
    });
  }

  // Fetch search results from API
  Future<Map<String, dynamic>> _fetchSearchResults(String query) async {
    try {
      final response = await _dio.get(
        'https://bookmass.fly.dev/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load search results');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection.');
      } else {
        throw Exception('Error: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  // Perform search
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchData = null;
    });

    try {
      final data = await _fetchSearchResults(query.trim());
      await _saveRecentSearch(query);

      setState(() {
        _searchData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      NotificationService.showError(e.toString());
    }
  }

  // Get filtered data based on selected filter
  List<dynamic> _getFilteredData() {
    if (_searchData == null) return [];

    switch (_selectedFilter) {
      case 'communities':
        return _searchData!['communities'] ?? [];
      case 'parishes':
        return _searchData!['parishes'] ?? [];
      case 'people':
        return _searchData!['people'] ?? [];
      default:
        // 'all' - combine all results
        return [
          ...(_searchData!['communities'] ?? []),
          ...(_searchData!['parishes'] ?? []),
          ...(_searchData!['people'] ?? []),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH BOX
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search communities, parishes, people...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: _performSearch,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchData = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),

            // FILTER CHIPS (Only show when there's search data)
            if (_searchData != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Communities', 'communities'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Parishes', 'parishes'),
                      const SizedBox(width: 8),
                      _buildFilterChip('People', 'people'),
                    ],
                  ),
                ),
              ),

            // CONTENT AREA
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchData == null
                      ? _buildRecentSearches()
                      : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  // Build Filter Chip
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Colors.blue[600],
      checkmarkColor: Colors.white,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
        width: 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // Build Recent Searches
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Search for communities,\nparishes, and people',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _clearRecentSearches,
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentSearches.map((search) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(search),
                trailing: const Icon(Icons.north_west, size: 18),
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              ),
            )),
      ],
    );
  }

  // Build Search Results
  Widget _buildSearchResults() {
    final filteredData = _getFilteredData();

    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        final collectionName = item['collectionName'] as String?;
        // Determine item type and render accordingly
        if (collectionName == 'prayer_community') {
          final newMap = Map<String, dynamic>.from(item);
          newMap['image'] = getPocketBaseFromContext(context)
              .getFileUrl(RecordModel.fromJson(newMap), newMap['image'])
              .toString();
          newMap['leader'] = <String, dynamic>{};
          newMap['members'] = newMap['members'].length;

          return CommunityCard(community: PrayerCommunity.fromMap(newMap));
        } else if (collectionName == 'parish') {
          return ParishCard(parish: item);
        } else if (collectionName == 'users') {
          final RecordModel person = RecordModel.fromJson(item);
          return UserCard(
              id: person.id,
              name:
                  '${person.getStringValue('first_name')} ${person.getStringValue('last_name')}',
              username: person.getStringValue('username'),
              followers: person.getListValue('followers').length.toString(),
              isFollowing: person.getListValue('followers').contains(
                  getPocketBaseFromContext(context).authStore.model?.id),
              onFollowTap: () {
                // Implement follow/unfollow logic here
                followUser(context, targetUserId: person.id);
                // setState(() {}); // Refresh UI
              },
              profilePicture: getPocketBaseFromContext(context)
                  .getFileUrl(person, person.getStringValue('avatar'))
                  .toString());
        }

        return const SizedBox.shrink();
      },
    );
  }
}
