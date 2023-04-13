import 'package:flutter/material.dart';

class ClassicalCard extends StatelessWidget {
  String titre;
  int nbRep;
  int poids;
  ClassicalCard({
    super.key,
    required this.titre,
    required this.nbRep,
    required this.poids,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.blue,
              width: 300,
              child: Text(
                titre,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontSize: 32),
              ),
            ),
            FlutterLogo(size: 300),
            Text(
              '$nbRep répétitions à $poids KG',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
