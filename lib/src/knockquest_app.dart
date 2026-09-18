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
import 'state/auth_store.dart';
import 'services/notification_service.dart';

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
  final ValueNotifier<bool> _popupOpen = ValueNotifier<bool>(false);
  ThemeMode _themeMode = ThemeMode.dark;
  static const String _kThemeModeKey = 'knockquest_theme_mode';

  late final NavigatorObserver _routeObserver = _RouteTrackingObserver(
    onRouteChanged: (routeName) {
      if (routeName != null && routeName.isNotEmpty) {
        _currentRoute.value = routeName;
      }
    },
    onPopupChanged: (isOpen) => _popupOpen.value = isOpen,
  );

  @override
  void dispose() {
    _currentRoute.dispose();
    _popupOpen.dispose();
    super.dispose();
  }

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
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
      await prefs.setString(
        _kThemeModeKey,
        mode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {
      // ignore write errors
    }
  }

  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1D5BD7))
        .copyWith(
          primary: const Color(0xFF2459E8),
          secondary: const Color(0xFF0F887B),
          surface: const Color(0xFFFFFFFF),
          surfaceContainerHighest: const Color(0xFFE7EDFF),
          onSurface: const Color(0xFF101B3D),
          onSurfaceVariant: const Color(0xFF4B5B7B),
        );
    final base = ThemeData.from(colorScheme: colorScheme, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF4F7FF),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF4F7FF),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      dividerColor: const Color(0xFFDCE4F7),
      textTheme: base.textTheme
          .apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          )
          .copyWith(
            bodyLarge: base.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDCE4F7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDCE4F7)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          side: const BorderSide(color: Color(0xFFD9E1EC)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D5BD7),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF8FAAFF),
          onPrimary: const Color(0xFF07143B),
          secondary: const Color(0xFF7BE4D1),
          onSecondary: const Color(0xFF07342F),
          tertiary: const Color(0xFFB8C8FF),
          surface: const Color(0xFF162447),
          surfaceContainerHighest: const Color(0xFF26385C),
          onSurface: const Color(0xFFF6F8FF),
          onSurfaceVariant: const Color(0xFFC0CBE4),
        );
    final base = ThemeData.from(colorScheme: colorScheme, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0A1532),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0A1532),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      dividerColor: const Color(0xFF344568),
      textTheme: base.textTheme
          .apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          )
          .copyWith(
            bodyLarge: base.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF344568)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF344568)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          side: const BorderSide(color: Color(0xFF465A83)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthUser?>(
      valueListenable: AuthStore.instance.currentUser,
      builder: (context, user, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConfig.appName,
          themeMode: _themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          navigatorKey: _navigatorKey,
          navigatorObservers: <NavigatorObserver>[_routeObserver],
          initialRoute: user == null ? AppRoutes.login : AppRoutes.dashboard,
          builder: (context, child) {
            if (child == null) {
              return const SizedBox.shrink();
            }

            NotificationService.instance.setContext(context);

            return ValueListenableBuilder<String>(
              valueListenable: _currentRoute,
              builder: (context, routeName, _) {
                if (routeName != AppRoutes.dashboard &&
                    routeName != AppRoutes.interactiveMap) {
                  return child;
                }

                return ValueListenableBuilder<bool>(
                  valueListenable: _popupOpen,
                  builder: (context, popupOpen, _) {
                    if (popupOpen) return child;
                    return Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(child: child),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: SafeArea(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 720,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withValues(alpha: 0.96),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).shadowColor.withValues(alpha: 0.14),
                                          blurRadius: 14,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        _MobileNavButton(
                                          tooltip: 'Dashboard',
                                          icon: Icons.dashboard_outlined,
                                          label: 'Dashboard',
                                          backgroundColor: const Color(
                                            0xFF0F9D58,
                                          ),
                                          onPressed:
                                              routeName == AppRoutes.dashboard
                                              ? null
                                              : () => _navigatorKey.currentState
                                                    ?.pushNamed(
                                                      AppRoutes.dashboard,
                                                    ),
                                        ),
                                        _MobileNavButton(
                                          tooltip: 'Add lead',
                                          icon: Icons.person_add_alt_1,
                                          label: 'Add Lead',
                                          backgroundColor: const Color(
                                            0xFF1D5BD7,
                                          ),
                                          onPressed: () => _navigatorKey
                                              .currentState
                                              ?.pushNamed(AppRoutes.addLead),
                                        ),
                                        _MobileNavButton(
                                          tooltip: 'Open map',
                                          icon: Icons.map_outlined,
                                          label: 'Map',
                                          backgroundColor: const Color(
                                            0xFF13B7D8,
                                          ),
                                          onPressed:
                                              routeName ==
                                                  AppRoutes.interactiveMap
                                              ? null
                                              : () => _navigatorKey.currentState
                                                    ?.pushNamed(
                                                      AppRoutes.interactiveMap,
                                                    ),
                                        ),
                                        _MobileNavButton(
                                          tooltip: 'Follow ups',
                                          icon: Icons.calendar_today_outlined,
                                          label: 'Follow Ups',
                                          backgroundColor: const Color(
                                            0xFF52627C,
                                          ),
                                          onPressed: () => _navigatorKey
                                              .currentState
                                              ?.pushNamed(AppRoutes.followUps),
                                        ),
                                        _MobileNavButton(
                                          tooltip: 'Export',
                                          icon: Icons.ios_share_outlined,
                                          label: 'Export',
                                          backgroundColor: const Color(
                                            0xFF35C784,
                                          ),
                                          onPressed: () => _navigatorKey
                                              .currentState
                                              ?.pushNamed(AppRoutes.analytics),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
      },
    );
  }
}

class _RouteTrackingObserver extends NavigatorObserver {
  _RouteTrackingObserver({
    required this.onRouteChanged,
    required this.onPopupChanged,
  });

  final ValueChanged<String?> onRouteChanged;
  final ValueChanged<bool> onPopupChanged;

  void _notify(Route<dynamic>? route) {
    onRouteChanged(route?.settings.name);
    onPopupChanged(route is PopupRoute);
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
        ? Theme.of(context).textTheme.bodySmall?.color ??
              const Color(0xFF5F7391)
        : Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.6) ??
              const Color(0xFF98A6BB);
    final iconBackground = enabled
        ? backgroundColor
        : backgroundColor.withValues(alpha: 0.5);
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
                child: Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
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
