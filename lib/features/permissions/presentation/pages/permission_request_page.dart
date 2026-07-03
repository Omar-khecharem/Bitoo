import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/permission_state.dart';
import '../providers/permission_provider.dart';
import '../widgets/permission_card.dart';

class PermissionRequestPage extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const PermissionRequestPage({super.key, required this.onComplete});

  @override
  ConsumerState<PermissionRequestPage> createState() =>
      _PermissionRequestPageState();
}

class _PermissionRequestPageState
    extends ConsumerState<PermissionRequestPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final permissions = ref.watch(permissionStateProvider);
    final notifier = ref.read(permissionStateProvider.notifier);

    final pages = [
      _buildPage(
        child: PermissionCard.media(
          status: permissions.media,
          onRequest: () => notifier.requestMedia(),
          onOpenSettings: () => ph.openAppSettings(),
        ),
      ),
      _buildPage(
        child: PermissionCard.notifications(
          status: permissions.notifications,
          onRequest: () => notifier.requestNotifications(),
          onOpenSettings: () => ph.openAppSettings(),
        ),
      ),
      _buildPage(
        child: PermissionCard.bluetooth(
          status: permissions.bluetooth,
          onRequest: () => notifier.requestBluetooth(),
          onOpenSettings: () => ph.openAppSettings(),
        ),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: List.generate(pages.length, (i) {
                    final isActive = i <= _currentPage;
                    final isGranted = i == 0
                        ? permissions.media is AppPermissionGranted
                        : i == 1
                            ? permissions.notifications is AppPermissionGranted
                            : permissions.bluetooth is AppPermissionGranted;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isActive
                              ? (isGranted
                                  ? colorScheme.primary
                                  : colorScheme.primary.withValues(alpha: 0.4))
                              : colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  _titles[_currentPage],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) =>
                      setState(() => _currentPage = i),
                  children: pages,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: _buildBottomAction(notifier, permissions),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          child,
          const SizedBox(height: 24),
          Text(
            'Step ${_currentPage + 1} of 3',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(
    PermissionStateNotifier notifier,
    AllPermissionsState permissions,
  ) {
    final isLast = _currentPage == 2;

    if (isLast && notifier.isComplete) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: _ContinueButton(onPressed: widget.onComplete),
      );
    }

    final currentGranted = _currentPage == 0
        ? permissions.media is AppPermissionGranted
        : _currentPage == 1
            ? permissions.notifications is AppPermissionGranted
            : permissions.bluetooth is AppPermissionGranted;

    return Row(
      children: [
        if (!isLast)
          TextButton(
            onPressed: () => _goNext(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
            child: const Text('Skip'),
          ),
        const Spacer(),
        if (currentGranted)
          _GlassNextButton(onPressed: _goNext)
        else
          TextButton(
            onPressed: _goNext,
            child: Text(
              'Next',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    );
  }

  void _goNext() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onComplete();
    }
  }

  static const _titles = [
    'Access Your Music',
    'Playback Controls',
    'Wireless Features',
  ];
}

class _GlassNextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GlassNextButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.3),
              colorScheme.primary.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            'Next',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ContinueButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.tertiary],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Start Listening',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
