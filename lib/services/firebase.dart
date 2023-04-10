import 'package:firebase_auth/firebase_auth.dart';

class DBFirebase {
  // function to get tu current user

  Future signup(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(userCredential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      return null;
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
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  Future updatePassword(String password) async {
    User? user = await _getUser();
    if (user != null) {
      await user.updatePassword(password);
    }
  }

  Future login(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
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
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  Future _getUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      return user;
    }
  }

  // function to get user uid
  Future _getUid() async {
    User? user = await _getUser();
    if (user != null) {
      return user.uid;
    }
  }

  // function to get user email
  Future _getEmail() async {
    User? user = await _getUser();
    if (user != null) {
      return user.email;
    }
  }

  // function to get user email
  Future _getDisplayName() async {
    User? user = await _getUser();
    if (user != null) {
      return user.displayName;
    }
  }

  // function to get user email
  Future _getPhotoURL() async {
    User? user = await _getUser();
    if (user != null) {
      return user.photoURL;
    }
  }

  // function to get user email
  Future _getPhoneNumber() async {
    User? user = await _getUser();
    if (user != null) {
      return user.phoneNumber;
    }
  }

  // function to get user email
  Future _getIsEmailVerified() async {
    User? user = await _getUser();
    if (user != null) {
      return user.emailVerified;
    }
  }
}
