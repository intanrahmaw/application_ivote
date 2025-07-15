class Candidate {
  final String candidateId;
  final String electionId;
  final String nama;
  final String visi;
  final String misi;
  final DateTime created;
  final DateTime updated;
  final String? foto;

  Candidate({
    required this.candidateId,
    required this.electionId,
    required this.nama,
    required this.visi,
    required this.misi,
    required this.created,
    required this.updated,
    this.foto,
  });

 factory Candidate.fromMap(Map<String, dynamic> map) {
  return Candidate(
    candidateId: map['candidate_id'] ?? '',
    electionId: map['election_id'] ?? '',
    nama: map['nama'] ?? '',
    visi: map['visi'] ?? '',
    misi: map['misi'] ?? '',
    foto: map['foto'] ?? '',
    created: map['created_at'] != null
        ? DateTime.parse(map['created_at'])
        : DateTime.now(),
    updated: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'])
        : DateTime.now(),
  );
}

}
