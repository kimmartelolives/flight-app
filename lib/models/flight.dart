class Flight {
  final String departure;
  final String destination;
  final String departureTime;
  final String arrivalTime;

  Flight({
    this.departure = 'Philippines', // Always from the Philippines
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
  });
}
