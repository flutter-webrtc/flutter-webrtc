class StatsReport {
  StatsReport(this.id, this.type, this.timestamp, this.values);
  final String id;
  final String type;
  final double timestamp;
  final Map<dynamic, dynamic> values;
}
