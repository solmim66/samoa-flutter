class PriceSettings {
  final String fridayEntrance;
  final String fridayDinner;
  final String saturdayEntrance;
  final String saturdayDinner;
  final String otherEntrance;
  final String otherDinner;

  const PriceSettings({
    required this.fridayEntrance,
    required this.fridayDinner,
    required this.saturdayEntrance,
    required this.saturdayDinner,
    required this.otherEntrance,
    required this.otherDinner,
  });

  static const defaults = PriceSettings(
    fridayEntrance: '€. 8',
    fridayDinner: '€. 18',
    saturdayEntrance: '€. 10',
    saturdayDinner: '€. 20',
    otherEntrance: '€. 5',
    otherDinner: '€. 15',
  );

  factory PriceSettings.fromMap(Map<String, dynamic> map) => PriceSettings(
        fridayEntrance:
            map['friday_entrance'] as String? ?? defaults.fridayEntrance,
        fridayDinner: map['friday_dinner'] as String? ?? defaults.fridayDinner,
        saturdayEntrance:
            map['saturday_entrance'] as String? ?? defaults.saturdayEntrance,
        saturdayDinner:
            map['saturday_dinner'] as String? ?? defaults.saturdayDinner,
        otherEntrance:
            map['other_entrance'] as String? ?? defaults.otherEntrance,
        otherDinner: map['other_dinner'] as String? ?? defaults.otherDinner,
      );

  Map<String, dynamic> toMap() => {
        'friday_entrance': fridayEntrance,
        'friday_dinner': fridayDinner,
        'saturday_entrance': saturdayEntrance,
        'saturday_dinner': saturdayDinner,
        'other_entrance': otherEntrance,
        'other_dinner': otherDinner,
      };
}
