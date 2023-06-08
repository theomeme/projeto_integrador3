class Emergency {
  final String id;
  final String name;
  final String phoneNumber;
  final String status;
  final List<String> photos;
  final DateTime createdAt;

  Emergency(
    this.id,
    this.createdAt, {
    required this.name,
    required this.phoneNumber,
    required this.status,
    required this.photos,
  });
}
