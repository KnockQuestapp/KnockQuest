import 'package:flutter/foundation.dart';

import '../sample_data.dart';

class LeadStore {
  LeadStore._();

  static final LeadStore instance = LeadStore._();

  final ValueNotifier<List<LeadRecord>> leads =
      ValueNotifier<List<LeadRecord>>([sampleLead]);

  final ValueNotifier<List<FollowUpRecord>> followUpsNotifier =
      ValueNotifier<List<FollowUpRecord>>(List<FollowUpRecord>.from(followUps));

    final ValueNotifier<List<QuestRecord>> questsNotifier =
      ValueNotifier<List<QuestRecord>>(List<QuestRecord>.from(quests));

  void addLead(LeadRecord lead) {
    leads.value = [...leads.value, lead];
  }

  LeadRecord get latestLead => leads.value.isEmpty ? sampleLead : leads.value.last;

  void addFollowUp(FollowUpRecord followUp) {
    followUpsNotifier.value = [...followUpsNotifier.value, followUp];
  }

  void markFollowUpCompleted(int index) {
    if (index < 0 || index >= followUpsNotifier.value.length) {
      return;
    }

    final current = [...followUpsNotifier.value];
    current[index] = current[index].copyWith(completed: true);
    followUpsNotifier.value = current;
  }

  void addQuest(QuestRecord quest) {
    questsNotifier.value = [...questsNotifier.value, quest];
  }

  void markQuestCompleted(int index) {
    if (index < 0 || index >= questsNotifier.value.length) {
      return;
    }

    final current = [...questsNotifier.value];
    current[index] = current[index].copyWith(completed: true, status: 'Completed');
    questsNotifier.value = current;
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
  }

  void reset() {
    leads.value = [sampleLead];
    followUpsNotifier.value = List<FollowUpRecord>.from(followUps);
    questsNotifier.value = List<QuestRecord>.from(quests);
  }
}
