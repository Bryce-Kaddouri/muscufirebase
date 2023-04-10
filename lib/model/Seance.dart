import 'Exo.dart';

class Seance {
  final String docId;
  final List<Exo> exos;
  final String titre;
  final DateTime createdAt;
  final DateTime updatedAt;

  Seance(
      {required this.docId,
      required this.exos,
      required this.titre,
      required this.createdAt,
      required this.updatedAt});

  factory Seance.fromMap(Map<String, dynamic> data, String docId) {
    return Seance(
      docId: docId,
      titre: data['titre'],
      exos: data['exos'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }
}
