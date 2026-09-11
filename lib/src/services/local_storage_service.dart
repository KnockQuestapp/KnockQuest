import 'package:hive_flutter/hive_flutter.dart';
import '../sample_data.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const String _leadsBoxName = 'leads_box';
  static const String _followUpsBoxName = 'followups_box';
  static const String _questsBoxName = 'quests_box';
  static const String _territoriesBoxName = 'territories_box';

  Future<void> init() async {
    await Hive.initFlutter();

    // We store records as Maps since we aren't using Hive TypeAdapters for simplicity in MVP
    await Hive.openBox(_leadsBoxName);
    await Hive.openBox(_followUpsBoxName);
    await Hive.openBox(_questsBoxName);
    await Hive.openBox(_territoriesBoxName);
  }

  // Leads
  Future<void> saveLeads(List<LeadRecord> leads) async {
    final box = Hive.box(_leadsBoxName);
    await box.clear();
    for (var i = 0; i < leads.length; i++) {
      await box.put(i, leads[i].toMap());
    }
  }

  List<LeadRecord> loadLeads() {
    final box = Hive.box(_leadsBoxName);
    return box.values
        .map((item) => LeadRecord.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Follow-ups
  Future<void> saveFollowUps(List<FollowUpRecord> followUps) async {
    final box = Hive.box(_followUpsBoxName);
    await box.clear();
    for (var i = 0; i < followUps.length; i++) {
      await box.put(i, followUps[i].toMap());
    }
  }

  List<FollowUpRecord> loadFollowUps() {
    final box = Hive.box(_followUpsBoxName);
    return box.values
        .map((item) => FollowUpRecord.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Quests
  Future<void> saveQuests(List<QuestRecord> quests) async {
    final box = Hive.box(_questsBoxName);
    await box.clear();
    for (var i = 0; i < quests.length; i++) {
      await box.put(i, quests[i].toMap());
    }
  }

  List<QuestRecord> loadQuests() {
    final box = Hive.box(_questsBoxName);
    return box.values
        .map((item) => QuestRecord.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Territories
  Future<void> saveTerritories(List<TerritoryRecord> territories) async {
    final box = Hive.box(_territoriesBoxName);
    await box.clear();
    for (var i = 0; i < territories.length; i++) {
      await box.put(i, territories[i].toMap());
    }
  }

  List<TerritoryRecord> loadTerritories() {
    final box = Hive.box(_territoriesBoxName);
    return box.values
        .map((item) => TerritoryRecord.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}
