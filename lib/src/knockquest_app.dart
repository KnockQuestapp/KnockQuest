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

        return ValueListenableBuilder<String>(
          valueListenable: _currentRoute,
          builder: (context, routeName, _) {
            if (routeName == AppRoutes.login) {
              return child;
            }

            return Stack(
              children: <Widget>[
                child,
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 14,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              _MobileNavButton(
                                tooltip: 'Dashboard',
                                icon: Icons.dashboard_outlined,
                                label: 'Dashboard',
                                backgroundColor: const Color(0xFF0F9D58),
                                onPressed: () =>
                                    _navigatorKey.currentState?.pushNamed(
                                      AppRoutes.dashboard,
                                    ),
                              ),
                              _MobileNavButton(
                                tooltip: 'Add lead',
                                icon: Icons.person_add_alt_1,
                                label: 'Add Lead',
                                backgroundColor: const Color(0xFF1D5BD7),
                                onPressed: () =>
                                    _navigatorKey.currentState?.pushNamed(
                                      AppRoutes.addLead,
                                    ),
                              ),
                              _MobileNavButton(
                                tooltip: 'Open map',
                                icon: Icons.map_outlined,
                                label: 'Map',
                                backgroundColor: const Color(0xFF13B7D8),
                                onPressed: () =>
                                    _navigatorKey.currentState?.pushNamed(
                                      AppRoutes.interactiveMap,
                                    ),
                              ),
                              _MobileNavButton(
                                tooltip: 'Follow ups',
                                icon: Icons.calendar_today_outlined,
                                label: 'Follow Ups',
                                backgroundColor: const Color(0xFF52627C),
                                onPressed: () =>
                                    _navigatorKey.currentState?.pushNamed(
                                      AppRoutes.followUps,
                                    ),
                              ),
                              _MobileNavButton(
                                tooltip: 'Export',
                                icon: Icons.ios_share_outlined,
                                label: 'Export',
                                backgroundColor: const Color(0xFF35C784),
                                onPressed: () =>
                                    _navigatorKey.currentState?.pushNamed(
                                      AppRoutes.analytics,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  class _MobileNavButton extends StatelessWidget {
    const _MobileNavButton({
      required this.tooltip,
      required this.icon,
      required this.label,
      required this.onPressed,
      this.backgroundColor = const Color(0xFF1D5BD7),
    });

    final String tooltip;
    final IconData icon;
    final String label;
    final VoidCallback? onPressed;
    final Color backgroundColor;

    @override
    Widget build(BuildContext context) {
      final enabled = onPressed != null;
      final labelColor = enabled
          ? const Color(0xFF5F7391)
          : const Color(0xFF98A6BB);
      final iconBackground = enabled
          ? backgroundColor
          : backgroundColor.withValues(alpha: 0.5);
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
