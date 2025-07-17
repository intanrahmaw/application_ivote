class Elections {
  final String electionId;
  final String judul;
  final String deskripsi;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;

  Elections({
    required this.electionId,
    required this.judul,
    required this.deskripsi,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory Elections.fromJson(Map<String, dynamic> json) {
    return Elections(
      electionId: json['elections_id'].toString(),
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elections_id': electionId,
      'judul': judul,
      'deskripsi': deskripsi,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_active': isActive,
    };
  }
}
