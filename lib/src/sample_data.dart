class LeadRecord {
  const LeadRecord({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.unitNumber,
    required this.city,
    required this.postalCode,
    required this.notes,
    required this.latitude,
    required this.longitude,
    required this.lastContactDate,
    required this.followUpDate,
    this.status = 'Active Lead',
    this.outcome = 'Door Knocking',
    this.estimatedValue = r'$450,000',
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final String unitNumber;
  final String city;
  final String postalCode;
  final String notes;
  final double latitude;
  final double longitude;
  final DateTime lastContactDate;
  final DateTime followUpDate;
  final String status;
  final String outcome;
  final String estimatedValue;

  String get name => '$firstName $lastName';

  LeadRecord copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
    String? unitNumber,
    String? city,
    String? postalCode,
    String? notes,
    double? latitude,
    double? longitude,
    DateTime? lastContactDate,
    DateTime? followUpDate,
    String? status,
    String? outcome,
    String? estimatedValue,
  }) {
    return LeadRecord(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      unitNumber: unitNumber ?? this.unitNumber,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      followUpDate: followUpDate ?? this.followUpDate,
      status: status ?? this.status,
      outcome: outcome ?? this.outcome,
      estimatedValue: estimatedValue ?? this.estimatedValue,
    );
  }
}

class FollowUpRecord {
  const FollowUpRecord({
    required this.name,
    required this.address,
    required this.note,
    required this.when,
    required this.priorityColor,
    this.completed = false,
  });

  final String name;
  final String address;
  final String note;
  final String when;
  final int priorityColor;
  final bool completed;

  FollowUpRecord copyWith({
    String? name,
    String? address,
    String? note,
    String? when,
    int? priorityColor,
    bool? completed,
  }) {
    return FollowUpRecord(
      name: name ?? this.name,
      address: address ?? this.address,
      note: note ?? this.note,
      when: when ?? this.when,
      priorityColor: priorityColor ?? this.priorityColor,
      completed: completed ?? this.completed,
    );
  }
}

class TerritoryRecord {
  const TerritoryRecord({
    required this.name,
    required this.gci,
    required this.leads,
    required this.change,
  });

  final String name;
  final String gci;
  final String leads;
  final String change;
}

class QuestRecord {
  const QuestRecord({
    required this.title,
    required this.status,
    required this.details,
    this.completed = false,
  });

  final String title;
  final String status;
  final String details;
  final bool completed;

  QuestRecord copyWith({
    String? title,
    String? status,
    String? details,
    bool? completed,
  }) {
    return QuestRecord(
      title: title ?? this.title,
      status: status ?? this.status,
      details: details ?? this.details,
      completed: completed ?? this.completed,
    );
  }
}

final sampleLead = LeadRecord(
  firstName: 'Jane',
  lastName: 'Doe',
  phone: '(555) 010-1298',
  email: 'jane.doe@example.com',
  address: '123 Main Street',
  unitNumber: '102',
  city: 'Metro City',
  postalCode: '10001',
  notes: 'Met owner at property, follow-up requested.',
  latitude: 40.7580,
  longitude: -73.9855,
  lastContactDate: DateTime(2026, 7, 29),
  followUpDate: DateTime(2026, 8, 8),
);

const followUps = [
  FollowUpRecord(
    name: 'Marcus Holloway',
    address: '482 Oak St, Unit 201',
    note: 'Spoke To Owner',
    when: 'Yesterday',
    priorityColor: 0xFF25C06D,
  ),
  FollowUpRecord(
    name: 'Sarah Jenkins',
    address: '1290 Bayview Ave',
    note: 'Interested',
    when: '2 Days Ago',
    priorityColor: 0xFFFFA600,
  ),
  FollowUpRecord(
    name: 'David Chen',
    address: '18 River Park Road',
    note: 'Appointment Set',
    when: '10:30 AM',
    priorityColor: 0xFF1D5BD7,
  ),
];

const territories = [
  TerritoryRecord(
    name: 'Oakwood Heights',
    gci: '\$42,500 GCI',
    leads: '128 Leads',
    change: '4.2%',
  ),
];

const quests = [
  QuestRecord(
    title: 'Park Cleanup Patrol',
    status: 'Draft',
    details: 'Seed quest used for migration verification and UI smoke checks.',
  ),
  QuestRecord(
    title: 'Community Food Drive',
    status: 'Planned',
    details: 'Next feature milestone after map routing and account migration.',
  ),
];
