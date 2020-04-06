class StatsReport {
  String id;
  String type;
  double timestamp;
  Map<dynamic, dynamic> values;

  factory StatsReport.fromMap(Map<dynamic, dynamic> map) {
    return new StatsReport(
        map['id'], map['type'], map['timestamp'], map['values']);
  }

  StatsReport(this.id, this.type, this.timestamp, this.values);
}
