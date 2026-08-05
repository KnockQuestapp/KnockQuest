class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const dashboard = '/dashboard';
  static const addLead = '/add-lead';
  static const interactiveMap = '/interactive-map';
  static const followUps = '/follow-ups';
  static const leadDetails = '/lead-details';
  static const visitHistory = '/visit-history';
  static const territories = '/territories';
  static const analytics = '/analytics';
  static const integrations = '/integrations';
  static const subscriptions = '/subscriptions';
  static const quests = '/quests';
  static const unknown = '/unknown';

  static const all = <String>[
    login,
    dashboard,
    addLead,
    interactiveMap,
    followUps,
    leadDetails,
    visitHistory,
    territories,
    analytics,
    integrations,
    subscriptions,
    quests,
  ];
}
