import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DBFirebase {
  // function to get tu current user
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<bool> signup(String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      DBFirebase().sendEmailVerification(userCredential);
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  Future sendEmailVerification(UserCredential userCredential) async {
    print('user email :');
    User? user = userCredential.user;
    print(user!.email);
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  Future resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  Future updatePassword(String password) async {
    User? user = await getCurrentUser();
    if (user != null) {
      await user.updatePassword(password);
    }
  }

  Future login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }

  Future logout() async {
    try {
      await auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  Future getCurrentUser() async {
    User? user = auth.currentUser;
    if (user != null) {
      return user;
    } else {
      return null;
    }
  }

  // function to get user uid
  getSeancesByUserId(String uid) {
    return FirebaseFirestore.instance.collection(uid).snapshots();
  }

  deleteSeanceById(String id) {
    User? user = auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection(user.uid).doc(id).delete();
    }
  }

  addSeance(
    String titre,
  ) {
    User? user = auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection(user.uid).add({
        'titre': titre,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    }
  }

  getNnExoBySeance(String idSeance) {
    User? user = auth.currentUser;
    var db = FirebaseFirestore.instance;
    if (user != null) {
      return db
          .collection(user.uid)
          .doc(idSeance)
          .collection('exos')
          .orderBy('index')
          .get();
    }
  }

  getExosBySeance(String idSeance) {
    User? user = auth.currentUser;
    var db = FirebaseFirestore.instance;
    if (user != null) {
      return db
          .collection(user.uid)
          .doc(idSeance)
          .collection('exos')
          .orderBy('index')
          .snapshots();
    }
  }

  addExo(
    String titre,
    int nbRep,
    int poids,
    int timer,
    String idSeance,
  ) async {
    User? user = auth.currentUser;
    var db = FirebaseFirestore.instance;
    if (user != null) {
      var exos =
          await db.collection(user!.uid).doc(idSeance).collection('exos').get();
      db.collection(user.uid).doc(idSeance).collection('exos').add({
        'titre': titre,
        'index': exos.size + 1,
        'nbRep': nbRep,
        'poids': poids,
        'timer': timer,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      }).then((value) {
        return true;
      }).catchError((error) {
        return false;
      });
    }
  }

  deleteExoById(String idSeance, String idExo) {
    User? user = auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection(user.uid)
          .doc(idSeance)
          .collection('exos')
          .doc(idExo)
          .delete();
      return true;
    } else {
      return false;
    }
  }

  changeOrder(String idUser, String idSeance, String idExo, int newIndex,
      int oldIndex) {
    try {
      final docRef = db
          .collection(idUser)
          .doc(idSeance)
          .collection('exos')
          .doc(idExo)
          .update({"index": newIndex});
      // var docRef = db
      //     .collection(idUser)
      //     .doc(idSeance)
      //     .collection('exos')
      //     .doc(idExo)
      //     .update({'index': newIndex});
      // var docRef1 = db
      //     .collection(idUser)
      //     .doc(idSeance)
      //     .collection('exos')
      //     .doc(idExo)
      //     .update({'index': oldIndex});
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  updateIndexExo(String idUser, String idSeance, String idExo, int newIndex) {
    try {
      var docRef = db
          .collection(idUser)
          .doc(idSeance)
          .collection('exos')
          .doc(idExo)
          .update({'index': newIndex});
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // function to get user email
  Future _getEmail() async {
    User? user = await getCurrentUser();
    if (user != null) {
      return user.email;
    }
  }

  // function to get user email
  Future _getDisplayName() async {
    User? user = await getCurrentUser();
    if (user != null) {
      return user.displayName;
    }
  }

  // function to get user email
  Future _getPhotoURL() async {
    User? user = await getCurrentUser();
    if (user != null) {
      return user.photoURL;
    }
  }

  // function to get user email
  Future _getPhoneNumber() async {
    User? user = await getCurrentUser();
    if (user != null) {
      return user.phoneNumber;
    }
  }

  // function to get user email
  Future _getIsEmailVerified() async {
    User? user = await getCurrentUser();
    if (user != null) {
      return user.emailVerified;
    }
  }
}
