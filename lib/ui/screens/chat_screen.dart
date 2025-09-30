import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/chat_cubit/chat_cubit.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/services/chat/chat_service.dart';
import 'package:oratio_app/ui/routes/route_names.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  int _selectedTabIndex = 0; // Track selected tab

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ChatCubit>().state is! ChatsLoaded) {
        context.read<ChatCubit>().loadRecentChats();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _showFloatingButton = _scrollController.offset > 200;
    });
  }

  Future<void> _refreshChats() async {
    await context.read<ChatCubit>().loadRecentChats();
  }

  Future<void> _errorCheck() async {
    if (context.read<ChatCubit>().state is ChatsLoaded) {
      if ((context.read<ChatCubit>().state as ChatsLoaded).chats.isEmpty) {
        await _refreshChats();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _errorCheck();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshChats,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: const AssetImage(
                  'assets/images/wallet_bg.jpeg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(.85), BlendMode.lighten)),
          ),
          child: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    floating: true,
                    snap: true,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    expandedHeight:
                        170, // Increased height to accommodate tab bar
                    flexibleSpace: FlexibleSpaceBar(
                      background: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              children: [
                                Text(
                                  'Chats',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Spacer(),
                                _buildContactsButton(),
                              ],
                            ),
                          ),
                          GestureDetector(
                              onTap: () async {
                                await context.pushNamed(RouteNames.searchPage);
                              },
                              child: _buildSearchBar()),
                          _buildCustomTabBar(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: Builder(
                builder: (context) {
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: BlocBuilder<ChatCubit, ChatState>(
                          builder: (context, state) {
                            if (state is ChatLoading) {
                              return const SliverToBoxAdapter(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (state is ChatsLoaded) {
                              // !Filter chats based on selected tab
                              final filteredChats = _selectedTabIndex == 0
                                  ? context.watch<ChatCubit>().getRecentChats()
                                  : context
                                      .watch<ChatCubit>()
                                      .getMessageRequests();
                              if (filteredChats.isEmpty) {
                                return const SliverToBoxAdapter(
                                  child: Center(
                                    child: Text('No chats available'),
                                  ),
                                );
                              }

                              return AnimationLimiter(
                                child: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      print([
                                        'current index ',
                                        filteredChats[index]
                                      ]);
                                      return AnimationConfiguration
                                          .staggeredList(
                                        position: index,
                                        duration:
                                            const Duration(milliseconds: 375),
                                        child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: ChatItem(
                                              index: index,
                                              chatPreview: filteredChats[index],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: filteredChats.length,
                                  ),
                                ),
                              );
                            } else if (state is ChatError) {
                              context.read<ChatCubit>().getRecentChats();
                              return SliverToBoxAdapter(
                                  child: Text(state.message));
                            }
                            return const SliverToBoxAdapter();
                          },
                        ),
                      ),
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Builder(builder: (context) {
                int unreadchats = 0;

                if (context.watch<ChatCubit>().state is ChatsLoaded) {
                  final chatsState =
                      context.watch<ChatCubit>().state as ChatsLoaded;
                  unreadchats = context
                      .watch<ChatCubit>()
                      .getRecentChats()
                      .fold(0, (sum, chat) {
                    return sum + chat.unreadCount;
                  });
                }
                return Badge(
                  isLabelVisible: unreadchats > 0,
                  label: Text(
                    unreadchats.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                  child: _buildTabItem(
                    title: 'Recent Chats',
                    isSelected: _selectedTabIndex == 0,
                    onTap: () => _onTabSelected(0),
                  ),
                );
              }),
            ),
            Expanded(
              child: Builder(builder: (context) {
                int unreadchats = 0;

                if (context.read<ChatCubit>().state is ChatsLoaded) {
                  final chatsState =
                      context.watch<ChatCubit>().state as ChatsLoaded;
                  unreadchats = context
                      .watch<ChatCubit>()
                      .getMessageRequests()
                      .fold(0, (sum, chat) {
                    return sum + chat.unreadCount;
                  });
                }
                return Badge(
                  isLabelVisible: unreadchats > 0,
                  label: Text(
                    unreadchats.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                  child: _buildTabItem(
                    title: 'Message Requests',
                    isSelected: _selectedTabIndex == 1,
                    onTap: () => _onTabSelected(1),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Widget _buildContactsButton() {
    return Material(
      color: Colors.transparent,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: IconButton(
          icon: const Icon(
            FontAwesomeIcons.addressBook,
            size: 18,
          ),
          onPressed: () async {
            // Handle profile tap
            if (await FlutterContacts.requestPermission()) {
              context.pushNamed(RouteNames.contacts);
            } else {
              NotificationService.showError(
                  "Permission to access contacts is needed");
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                FontAwesomeIcons.search,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text('Search friends...',
                style: TextStyle(color: Colors.black.withOpacity(0.5)))
          ],
        ),
      ),
    );
  }
}

class ChatItem extends StatefulWidget {
  final int index;
  final ChatPreview chatPreview;

  const ChatItem({super.key, required this.index, required this.chatPreview});

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String? getAvatarUrl() {
    final pb = context.read<PocketBaseServiceCubit>().state.pb;
    if (widget.chatPreview.profile.user.getStringValue('avatar').isNotEmpty) {
      final img = pb
          .getFileUrl(widget.chatPreview.profile.user,
              widget.chatPreview.profile.user.getStringValue('avatar'))
          .toString();
      if (img.isNotEmpty) {
        return img;
      }
    }
    return null;
  }

  String getInitials() {
    final firstName =
        widget.chatPreview.profile.user.getStringValue('first_name');
    final lastName =
        widget.chatPreview.profile.user.getStringValue('last_name');

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]} ${lastName[0]}';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => {
        context.pushNamed(RouteNames.chatDetailPage, pathParameters: {
          'profile': widget.chatPreview.profile.toJsonString(),
        })
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: getAvatarUrl() != null
                          ? CachedNetworkImageProvider(getAvatarUrl()!)
                          : null,
                      backgroundColor: getAvatarUrl() == null
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: getAvatarUrl() == null
                          ? Text(
                              getInitials(),
                              style: Theme.of(context).textTheme.titleLarge,
                            )
                          : null,
                    ),
                    if (widget.chatPreview.active)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.chatPreview.profile.user
                                .getStringValue('username'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            formatDateTimeToHoursAgo(
                                widget.chatPreview.lastMessageAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.chatPreview.preview,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.chatPreview.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${widget.chatPreview.unreadCount}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            )
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
    );
  }
}
