class Exo {
  String docId;
  String titre;
  int? poids;
  DateTime createdAt;
  DateTime updatedAt;
  int index;
  int nbRep;
  int? timer;

  Exo(
      {required this.docId,
      required this.titre,
      this.poids,
      required this.createdAt,
      required this.updatedAt,
      required this.index,
      required this.nbRep,
      this.timer});

  factory Exo.fromMap(Map<String, dynamic> data, String docId) {
    return Exo(
        docId: docId,
        titre: data['titre'],
        poids: data['poids'],
        createdAt: data['createdAt'].toDate(),
        updatedAt: data['updatedAt'].toDate(),
        index: data['index'],
        nbRep: data['nbRep'],
        timer: data['timer']);
  }

  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'poids': poids,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'index': index,
      'nbRep': nbRep,
      'timer': timer
    };
  }
}
