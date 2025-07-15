class Candidate {
  final String candidateId;
  final String electionId;
  final String nama;
  final String visi;
  final String misi;
  final String foto;
  final DateTime created;
  final DateTime updated;

  Candidate({
    required this.candidateId,
    required this.electionId,
    required this.nama,
    required this.visi,
    required this.misi,
    required this.foto,
    required this.created,
    required this.updated,
  });

  // Convert from Supabase JSON
  factory Candidate.fromMap(Map<String, dynamic> map) {
    return Candidate(
      candidateId: map['candidate_id'] ?? '',
      electionId: map['election_id'] ?? '',
      nama: map['nama'] ?? '',
      visi: map['visi'] ?? '',
      misi: map['misi'] ?? '',
      foto: map['foto'] ?? '',
      created: DateTime.parse(map['created_at']),
      updated: DateTime.parse(map['updated_at']),
    );
  }

  // Convert to Map for insertion/update
  Map<String, dynamic> toMap() {
    return {
      'candidate_id': candidateId,
      'election_id': electionId,
      'nama': nama,
      'visi': visi,
      'misi': misi,
      'foto': foto,
      'created_at': created.toIso8601String(),
      'updated_at': updated.toIso8601String(),
    };
  }
}
