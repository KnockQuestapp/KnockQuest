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

class KnockQuestApp extends StatelessWidget {
  const KnockQuestApp({super.key});

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
      initialRoute: AppRoutes.login,
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
