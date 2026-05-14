import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../view_models/profile_view_model.dart';
import '../../view_models/auth_view_model.dart';
import 'profile_view.dart';
import '../progress/progress_view.dart';

class ProfileProgressView extends ConsumerStatefulWidget {
  const ProfileProgressView({super.key});

  @override
  ConsumerState<ProfileProgressView> createState() =>
      _ProfileProgressViewState();
}

class _ProfileProgressViewState extends ConsumerState<ProfileProgressView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authViewModelProvider).currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 180,
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.secondaryText),
                onPressed: () {
                  ref.read(authViewModelProvider.notifier).logout();
                  context.go('/login');
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  color: AppColors.brandBlue,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(0)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              AppColors.surfaceWhite.withValues(alpha: 0.3),
                          child: Text(
                            _getInitials(authUser?.name ?? ''),
                            style: AppTextStyles.heading.copyWith(
                                color: AppColors.surfaceWhite),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authUser?.name ?? '-',
                                style: AppTextStyles.title.copyWith(
                                    color: AppColors.surfaceWhite),
                              ),
                              Text(
                                authUser?.email ?? '',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.surfaceWhite
                                        .withValues(alpha: 0.75)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.brandBlue,
              indicatorWeight: 3,
              labelColor: AppColors.brandBlue,
              unselectedLabelColor: AppColors.secondaryText,
              labelStyle: AppTextStyles.title
                  .copyWith(fontSize: 14),
              tabs: const [
                Tab(icon: Icon(Icons.person_rounded), text: 'Profil'),
                Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Progress'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            ProfileTab(),
            ProgressTab(),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isEmpty ? '?' : parts[0][0].toUpperCase();
  }
}
