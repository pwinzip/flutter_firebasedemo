import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signInwithGoogle() async {
  await Firebase.initializeApp();
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult =
      await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if (user != null) {
    final User currentUser = _auth.currentUser;

    print("${user.uid} : ${currentUser.uid}");

    print("SignInWithGoogle sucessful: $user");

    return user.displayName;
  }
  return null;
}

Future<void> googleSignOut() async {
  await _auth.signOut().then((value) {
    googleSignIn.signOut();
  });
}
