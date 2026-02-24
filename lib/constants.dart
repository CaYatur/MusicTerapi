class MoodOption {
  final String name;
  final String emoji;
  const MoodOption(this.name, this.emoji);
}

const List<MoodOption> kMoods = [
  MoodOption('Stresli', '😣'),
  MoodOption('Kaygılı', '😟'),
  MoodOption('Yorgun', '😴'),
  MoodOption('Odak', '🎯'),
  MoodOption('Mutsuz', '😔'),
];

const List<int> kSessionDurations = [5, 7, 10, 12, 15];
