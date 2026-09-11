import 'dart:async';

import 'package:flutter/foundation.dart';

import '../integrations/crm_sync_service.dart';
import '../sample_data.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';

class LeadStore {
  LeadStore._();

  static final LeadStore instance = LeadStore._();

  final ValueNotifier<List<LeadRecord>> leads =
      ValueNotifier<List<LeadRecord>>([sampleLead]);
  final ValueNotifier<List<FollowUpRecord>> followUpsNotifier =
      ValueNotifier<List<FollowUpRecord>>(List<FollowUpRecord>.from(followUps));
  final ValueNotifier<List<QuestRecord>> questsNotifier =
      ValueNotifier<List<QuestRecord>>(List<QuestRecord>.from(quests));
  final ValueNotifier<List<TerritoryRecord>> territoriesNotifier =
      ValueNotifier<List<TerritoryRecord>>(List<TerritoryRecord>.from(territories));

  bool _initialized = false;

  void init() async {
    if (_initialized) return;

    // Load from local storage first for offline-first experience
    final storedLeads = LocalStorageService.instance.loadLeads();
    if (storedLeads.isNotEmpty) {
      leads.value = storedLeads;
    }

    final storedFollowUps = LocalStorageService.instance.loadFollowUps();
    if (storedFollowUps.isNotEmpty) {
      followUpsNotifier.value = storedFollowUps;
    }

    final storedQuests = LocalStorageService.instance.loadQuests();
    if (storedQuests.isNotEmpty) {
      questsNotifier.value = storedQuests;
    }

    final storedTerritories = LocalStorageService.instance.loadTerritories();
    if (storedTerritories.isNotEmpty) {
      territoriesNotifier.value = storedTerritories;
    }

    // Sync with Supabase
    final cloudLeads = await SupabaseService.instance.fetchLeads();
    if (cloudLeads.isNotEmpty) {
      leads.value = cloudLeads;
      unawaited(LocalStorageService.instance.saveLeads(leads.value));
    }

    _initialized = true;
  }

  void addLead(LeadRecord lead) {
    leads.value = [...leads.value, lead];
    unawaited(LocalStorageService.instance.saveLeads(leads.value));
    unawaited(SupabaseService.instance.syncLeads(leads.value));
    unawaited(CrmSyncService.instance.syncLeadCreated(lead));
  }

  LeadRecord get latestLead => leads.value.isEmpty ? sampleLead : leads.value.last;

  void addFollowUp(FollowUpRecord followUp) {
    followUpsNotifier.value = [...followUpsNotifier.value, followUp];
    unawaited(LocalStorageService.instance.saveFollowUps(followUpsNotifier.value));
  }

  void markFollowUpCompleted(int index) {
    if (index < 0 || index >= followUpsNotifier.value.length) {
      return;
    }

    final current = [...followUpsNotifier.value];
    current[index] = current[index].copyWith(completed: true);
    followUpsNotifier.value = current;
    unawaited(LocalStorageService.instance.saveFollowUps(followUpsNotifier.value));
  }

  void addQuest(QuestRecord quest) {
    questsNotifier.value = [...questsNotifier.value, quest];
    unawaited(LocalStorageService.instance.saveQuests(questsNotifier.value));
  }

  void markQuestCompleted(int index) {
    if (index < 0 || index >= questsNotifier.value.length) {
      return;
    }

    final current = [...questsNotifier.value];
    current[index] = current[index].copyWith(completed: true, status: 'Completed');
    questsNotifier.value = current;
    unawaited(LocalStorageService.instance.saveQuests(questsNotifier.value));
  }

  void updateQuest(int index, QuestRecord quest) {
    if (index < 0 || index >= questsNotifier.value.length) {
      return;
    }

    final current = [...questsNotifier.value];
    current[index] = quest;
    questsNotifier.value = current;
    unawaited(LocalStorageService.instance.saveQuests(questsNotifier.value));
  }

  void deleteQuest(int index) {
    if (index < 0 || index >= questsNotifier.value.length) {
      return;
    }

    final current = [...questsNotifier.value]..removeAt(index);
    questsNotifier.value = current;
    unawaited(LocalStorageService.instance.saveQuests(questsNotifier.value));
  }

  void addTerritory(TerritoryRecord territory) {
    territoriesNotifier.value = [...territoriesNotifier.value, territory];
    unawaited(LocalStorageService.instance.saveTerritories(territoriesNotifier.value));
  }

  void updateTerritory(int index, TerritoryRecord territory) {
    if (index < 0 || index >= territoriesNotifier.value.length) {
      return;
    }

    final current = [...territoriesNotifier.value];
    current[index] = territory;
    territoriesNotifier.value = current;
    unawaited(LocalStorageService.instance.saveTerritories(territoriesNotifier.value));
  }

  void deleteTerritory(int index) {
    if (index < 0 || index >= territoriesNotifier.value.length) {
      return;
    }

    final current = [...territoriesNotifier.value]..removeAt(index);
    territoriesNotifier.value = current;
    unawaited(LocalStorageService.instance.saveTerritories(territoriesNotifier.value));
  }

  void updateLatestLead({
    String? status,
    String? outcome,
    String? notes,
    DateTime? lastContactDate,
  }) {
    if (leads.value.isEmpty) {
      return;
    }

    final current = [...leads.value];
    final latestIndex = current.length - 1;
    current[latestIndex] = current[latestIndex].copyWith(
      status: status,
      outcome: outcome,
      notes: notes,
      lastContactDate: lastContactDate,
    );
    leads.value = current;
    unawaited(LocalStorageService.instance.saveLeads(leads.value));
    unawaited(SupabaseService.instance.syncLeads(leads.value));
    unawaited(CrmSyncService.instance.syncLeadUpdated(current[latestIndex]));
  }

  void reset() {
    leads.value = [sampleLead];
    followUpsNotifier.value = List<FollowUpRecord>.from(followUps);
    questsNotifier.value = List<QuestRecord>.from(quests);
    territoriesNotifier.value = List<TerritoryRecord>.from(territories);
    unawaited(LocalStorageService.instance.saveLeads(leads.value));
    unawaited(LocalStorageService.instance.saveFollowUps(followUpsNotifier.value));
    unawaited(LocalStorageService.instance.saveQuests(questsNotifier.value));
    unawaited(LocalStorageService.instance.saveTerritories(territoriesNotifier.value));
  }
}
