enum MapProvider { osm, google }

class AppConfig {
  const AppConfig._();

  static const String appName = 'KnockQuest';

  static const MapProvider mapProvider =
      String.fromEnvironment('MAP_PROVIDER', defaultValue: 'osm') == 'google'
      ? MapProvider.google
      : MapProvider.osm;

  static const String appFlavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'production',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
