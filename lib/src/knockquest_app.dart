import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'config/app_config.dart';
import 'features/analytics/business_analytics_page.dart';
import 'features/auth/login_registration_page.dart';
import 'features/dashboard/main_dashboard_page.dart';
import 'features/followups/follow_ups_page.dart';
import 'features/integrations/crm_integrations_page.dart';
import 'features/leads/add_lead_page.dart';
import 'features/leads/lead_details_page.dart';
import 'features/leads/visit_logger_history_page.dart';
import 'features/map/interactive_map_page.dart';
import 'features/placeholder/unknown_route_page.dart';
import 'features/quests/quests_page.dart';
import 'features/subscription/subscription_themes_page.dart';
import 'features/territories/territory_management_page.dart';

class KnockQuestApp extends StatefulWidget {
  const KnockQuestApp({super.key});

  @override
  State<KnockQuestApp> createState() => _KnockQuestAppState();
}

class _KnockQuestAppState extends State<KnockQuestApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<String> _currentRoute = ValueNotifier<String>(
    AppRoutes.login,
  );

  late final NavigatorObserver _routeObserver = _RouteTrackingObserver(
    onRouteChanged: (routeName) {
      if (routeName != null && routeName.isNotEmpty) {
        _currentRoute.value = routeName;
      }
    },
  );

  static const _mobileNavDestinations = <_MobileNavDestination>[
    _MobileNavDestination(AppRoutes.dashboard, 'Dashboard', Icons.dashboard),
    _MobileNavDestination(AppRoutes.addLead, 'Add Lead', Icons.person_add),
    _MobileNavDestination(
      AppRoutes.interactiveMap,
      'Map',
      Icons.map_outlined,
    ),
    _MobileNavDestination(AppRoutes.followUps, 'Follow Ups', Icons.schedule),
    _MobileNavDestination(AppRoutes.quests, 'Quests', Icons.flag_outlined),
    _MobileNavDestination(
      AppRoutes.territories,
      'Territories',
      Icons.grid_view,
    ),
    _MobileNavDestination(
      AppRoutes.analytics,
      'Analytics',
      Icons.analytics_outlined,
    ),
    _MobileNavDestination(
      AppRoutes.integrations,
      'Integrations',
      Icons.hub_outlined,
    ),
    _MobileNavDestination(
      AppRoutes.subscriptions,
      'Subscriptions',
      Icons.workspace_premium_outlined,
    ),
  ];

  @override
  void dispose() {
    _currentRoute.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D5BD7)),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        bodySmall: TextStyle(color: Color(0xFF7E8CA0)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: Color(0xFFD9E1EC)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: theme,
      navigatorKey: _navigatorKey,
      navigatorObservers: <NavigatorObserver>[_routeObserver],
      initialRoute: AppRoutes.login,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        final isMobileViewport = MediaQuery.sizeOf(context).width < 720;
        if (!isMobileViewport) {
          return child;
        }

        return ValueListenableBuilder<String>(
          valueListenable: _currentRoute,
          builder: (context, routeName, _) {
            if (routeName == AppRoutes.login) {
              return child;
            }

            final canPop = _navigatorKey.currentState?.canPop() ?? false;
            return Stack(
              children: <Widget>[
                child,
                Positioned(
                  top: 12,
                  left: 12,
                  child: SafeArea(
                    child: Row(
                      children: <Widget>[
                        if (canPop)
                          _MobileNavButton(
                            tooltip: 'Back',
                            icon: Icons.arrow_back,
                            onPressed: () =>
                                _navigatorKey.currentState?.maybePop(),
                          ),
                        if (canPop) const SizedBox(width: 8),
                        _MobileNavButton(
                          tooltip: 'Open menu',
                          icon: Icons.menu,
                          onPressed: () =>
                              _openMobileMenu(context, routeName),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      routes: {
        AppRoutes.login: (_) => const LoginRegistrationPage(),
        AppRoutes.dashboard: (_) => const MainDashboardPage(),
        AppRoutes.addLead: (_) => const AddLeadPage(),
        AppRoutes.interactiveMap: (_) => const InteractiveMapPage(),
        AppRoutes.followUps: (_) => const FollowUpsPage(),
        AppRoutes.leadDetails: (_) => const LeadDetailsPage(),
        AppRoutes.visitHistory: (_) => const VisitLoggerHistoryPage(),
        AppRoutes.territories: (_) => const TerritoryManagementPage(),
        AppRoutes.analytics: (_) => const BusinessAnalyticsPage(),
        AppRoutes.integrations: (_) => const CrmIntegrationsPage(),
        AppRoutes.subscriptions: (_) => const SubscriptionThemesPage(),
        AppRoutes.quests: (_) => const QuestsPage(),
      },
      onUnknownRoute: (settings) {
        final routeName = settings.name ?? AppRoutes.unknown;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => UnknownRoutePage(routeName: routeName),
        );
      },
    );
  }

    Future<void> _openMobileMenu(BuildContext context, String currentRoute) async {
      final selectedRoute = await showModalBottomSheet<String>(
        context: context,
        useSafeArea: true,
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            children: <Widget>[
              for (final destination in _mobileNavDestinations)
                ListTile(
                  leading: Icon(destination.icon),
                  title: Text(destination.label),
                  selected: destination.route == currentRoute,
                  onTap: () => Navigator.of(context).pop(destination.route),
                ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: () => Navigator.of(context).pop(AppRoutes.login),
              ),
            ],
          );
        },
      );

      if (selectedRoute == null || selectedRoute == currentRoute) {
        return;
      }

      if (selectedRoute == AppRoutes.login) {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
        return;
      }

      _navigatorKey.currentState?.pushNamed(selectedRoute);
    }
}

  class _RouteTrackingObserver extends NavigatorObserver {
    _RouteTrackingObserver({required this.onRouteChanged});

    final ValueChanged<String?> onRouteChanged;

    void _notify(Route<dynamic>? route) {
      onRouteChanged(route?.settings.name);
    }

    @override
    void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
      _notify(route);
      super.didPush(route, previousRoute);
    }

    @override
    void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
      _notify(previousRoute);
      super.didPop(route, previousRoute);
    }

    @override
    void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
      _notify(newRoute);
      super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }

    @override
    void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
      _notify(previousRoute);
      super.didRemove(route, previousRoute);
    }
  }

  class _MobileNavDestination {
    const _MobileNavDestination(this.route, this.label, this.icon);

    final String route;
    final String label;
    final IconData icon;
  }

  class _MobileNavButton extends StatelessWidget {
    const _MobileNavButton({
      required this.tooltip,
      required this.icon,
      required this.onPressed,
    });

    final String tooltip;
    final IconData icon;
    final VoidCallback onPressed;

    @override
    Widget build(BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;
      return Material(
        elevation: 3,
        color: colorScheme.surface,
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: colorScheme.primary),
        ),
      );
    }
  }
