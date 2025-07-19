

class Candidate {
  final String candidateId;
  final String electionId;
  final String nama;
  final String organisasi;
  final String label;
  final String visi;
  final String misi;
  final DateTime created;
  final DateTime updated;
  final String? imageUrl;

  Candidate({
    required this.candidateId,
    required this.electionId,
    required this.nama,
    required this.organisasi,
    required this.label,
    required this.visi,
    required this.misi,
    required this.created,
    required this.updated,
    this.imageUrl,
  });

 factory Candidate.fromMap(Map<String, dynamic> map) {
  return Candidate(    
    candidateId: map['candidate_id']?.toString() ?? '',
    electionId: map['elections_id']?.toString() ?? '',
    nama: map['nama'] ?? '', 
    organisasi: map['organisasi'] ?? '', 
    label: map['label'] ?? '',    
    visi: map['visi'] ?? '',
    misi: map['misi'] ?? '',
    imageUrl: map['image_url'],
    created: map['created_at'] != null
        ? DateTime.parse(map['created_at'])
        : DateTime.now(),
    updated: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'])
        : DateTime.now(),
  );
}

}