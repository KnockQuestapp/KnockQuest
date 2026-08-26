import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  ThemeMode _themeMode = ThemeMode.light;
  static const String _kThemeModeKey = 'knockquest_theme_mode';

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

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    // persist selection
    _saveThemeMode(_themeMode);
  }

  @override
  void initState() {
    super.initState();
    // load persisted theme preference
    _loadSavedThemeMode();
  }

  Future<void> _loadSavedThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_kThemeModeKey);
      if (value == 'dark') {
        setState(() => _themeMode = ThemeMode.dark);
      } else if (value == 'light') {
        setState(() => _themeMode = ThemeMode.light);
      }
    } catch (_) {
      // ignore failures and keep default
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {
      // ignore write errors
    }
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D5BD7)),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
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
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1D5BD7),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: const TextTheme(
        bodySmall: TextStyle(color: Color(0xFFCBD5E1)),
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
          side: const BorderSide(color: Color(0xFF334155)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      themeMode: _themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
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

            final mediaQuery = MediaQuery.of(context);
            final dockReservedHeight = 92.0 + mediaQuery.padding.bottom;

            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: dockReservedHeight),
                    child: child,
                  ),
                ),
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A).withValues(alpha: 245)
                                : Theme.of(context).colorScheme.surface.withValues(alpha: 245),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0x66000000)
                                    : Theme.of(context).shadowColor.withValues(alpha: 36),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0x88000000)
                                    : const Color(0x22000000),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
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
        AppRoutes.dashboard: (_) => MainDashboardPage(
          isDarkMode: _themeMode == ThemeMode.dark,
          onThemeToggle: _toggleThemeMode,
        ),
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
          ? Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF5F7391)
          : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 153) ?? const Color(0xFF98A6BB);
      final iconBackground = enabled
          ? backgroundColor
          : backgroundColor.withValues(alpha: 128);
      return Material(
        color: Colors.transparent,
        child: InkWell(
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
                  child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onPrimary),
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
        ),
      );
    }
  }
