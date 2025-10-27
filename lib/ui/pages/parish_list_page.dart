import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';

class ParishListPage extends StatefulWidget {
  const ParishListPage({super.key});

  @override
  State<ParishListPage> createState() => _ParishListPageState();
}

class _ParishListPageState extends State<ParishListPage>
    with SingleTickerProviderStateMixin {
  // Controller for search bar animations
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;
  late PocketBase pb;
  final controller = TextEditingController();
  bool _isHovered = false;
  bool _loading = false;
  List<RecordModel> parish = [];

  @override
  void initState() {
    super.initState();
    pb = context.read<PocketBaseServiceCubit>().state.pb;
    // Initialize animation controller with 300ms duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchParishList();
    });
    // Create curved animation for smooth effect
    _searchBarAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start the animation when the page loads
    _animationController.forward();
  }

  Future fetchParishList() async {
    setState(() {
      _loading = true;
    });
    try {
      parish = await getParishList(context, onError: () {
        NotificationService.showError('An error occured loading parishe\'s');
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      _loading = false;
    });
  }

  Future handleSearch(String q) async {
    setState(() {
      _loading = true;
    });
    try {
      parish = await findParish(context, search: q);
    } catch (e) {
      print('searching error $e');
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        // Handle potential overflow with error boundary
        child: ErrorBoundary(
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              await fetchParishList();
            },
            child: CustomScrollView(
              physics:
                  const BouncingScrollPhysics(), // Smooth scrolling physics
              slivers: [
                // Sliver app bar with search
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(8), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildAppBar(context),
                        const Gap(8), // Reduced gap
                        // Animate search bar entrance
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.5),
                            end: Offset.zero,
                          ).animate(_searchBarAnimation),
                          child: FadeTransition(
                            opacity: _searchBarAnimation,
                            child: _buildSearchBar(controller),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Church list with staggered animations
                if (!_loading && parish.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          // Stagger the animations of list items
                          final itemAnimation = Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                (index * 0.1).clamp(0.0, 1.0),
                                ((index + 1) * 0.1).clamp(0.0, 1.0),
                                curve: Curves.easeOut,
                              ),
                            ),
                          );

                          return FadeTransition(
                            opacity: itemAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.2, 0),
                                end: Offset.zero,
                              ).animate(itemAnimation),
                              child: _buildChurchCard(context, parish[index]),
                            ),
                          );
                        },
                      ),
                      childCount: parish.length,
                    ),
                  )
                else if (_loading)
                  SliverToBoxAdapter(
                      child: SizedBox(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      ],
                    ),
                  ))
                else
                  const SliverToBoxAdapter(
                    child: SizedBox(
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text('No Parish Available'),
                            ),
                          ],
                        )),
                  )
              ],
            ),
          ),
        ),
      ),
      // Animated FAB
      floatingActionButton: ScaleTransition(
        scale: _searchBarAnimation,
        child: FloatingActionButton(
          onPressed: () {
            context.pushNamed(RouteNames.mass);
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.map_outlined, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(FontAwesomeIcons.chevronLeft, size: 16),
                padding: const EdgeInsets.all(8), // Reduced padding
              ),
              const Gap(8), // Reduced gap
              // Flexible text to prevent overflow
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mass Centers',
                      style: TextStyle(
                        fontSize: 20, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle text overflow
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(TextEditingController controller) {
    return TextField(
      onChanged: (val) {
        // TODO HANDLE SEACRH
        handleSearch(val);
      },
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search churches...',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        isDense: true, // Reduce input field height
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
    );
  }

  PopupMenuItem<void> _buildPopupMenuItem(
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    // Use StatefulBuilder to handle hover effects
    return PopupMenuItem<void>(
      onTap: onTap,
      height: 40, // Reduced height for better compactness
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: StatefulBuilder(
        builder: (context, setState) => InkWell(
          onTap: onTap,
          // Animate on hover
          onHover: (isHovered) => setState(() => _isHovered = isHovered),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _isHovered ? Colors.grey[100] : Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: _isHovered
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                  ),
                ),
                const Gap(8),
                // Animated text
                DefaultTextStyle(
                  style: TextStyle(
                    color: _isHovered
                        ? Theme.of(context).primaryColor
                        : Colors.grey[800],
                    fontSize: 14,
                    fontWeight:
                        _isHovered ? FontWeight.w500 : FontWeight.normal,
                  ),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add this boolean to your State class
  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 4), // Reduced padding
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (bool value) {},
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 4), // Reduced padding
        materialTapTargetSize:
            MaterialTapTargetSize.shrinkWrap, // Smaller touch target
      ),
    );
  }

  Widget _buildChurchCard(BuildContext context, RecordModel church) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(RouteNames.parishlanding, pathParameters: {
          'id': church.id,
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4), // Reduced margins
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8), // Reduced padding
          child: Row(
            children: [
              // Church image with error handling
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  pb
                      .getFileUrl(church, church.getStringValue('image'),
                          thumb: '60 x 60')
                      .toString(), // Reduced size
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  // Handle image load errors
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: Icon(Icons.church, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      church.getStringValue('name').toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 12, color: Colors.grey[600]),
                        const Gap(2),
                        Expanded(
                          child: Text(
                            church.getStringValue('location'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    // Row(
                    //   children: [
                    //     _buildInfoChip(Icons.access_time, '5 min'),
                    //     const Gap(4),
                    //     _buildInfoChip(Icons.calendar_today, '4 masses'),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.grey[600]),
          const Gap(2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Error boundary widget to handle potential errors
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: child,
    );
  }
}
