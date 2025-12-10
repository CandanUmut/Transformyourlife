class LearnCard {
  LearnCard({
    required this.id,
    required this.title,
    required this.category,
    required this.body,
    this.tryThis,
  });

  final String id;
  final String title;
  final String category;
  final String body;
  final String? tryThis;
}
