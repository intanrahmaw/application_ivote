class Election {
  final String electionId;
  final String judul;
  final String deskripsi;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;

  Election({
    required this.electionId,
    required this.judul,
    required this.deskripsi,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

   factory Election.fromJson(Map<String, dynamic> json) {
    return Election(
      electionId: json['id'].toString(),
      judul: json['nama'],
      deskripsi: json['deskripsi'],
      startTime: DateTime.parse(json['tanggal_mulai']),
      endTime: DateTime.parse(json['tanggal_selesai']),
      isActive: json['is_active'] ?? false,
    );
   }
}
