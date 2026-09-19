import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseHelper {
  static final CollectionReference tasksCollection = FirebaseFirestore.instance
      .collection('tasks');
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<void> addTask({
    required String title,
    required String description,
    required DateTime time,
  }) async {
    try {
      await tasksCollection.add({
        'title': title,
        'description': description,
        'time': Timestamp.fromDate(time),
        'isDone': false,
        'createdAt': FieldValue.serverTimestamp(),
        'ownerId': _auth.currentUser?.uid,
      });
    } catch (e) {
      throw Exception('Could not add the task: $e');
    }
  }

  static Stream<QuerySnapshot> getTasksStream() {
    return tasksCollection.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> updateTaskStatus(String docId, bool isDone) async {
    try {
      await tasksCollection.doc(docId).update({'isDone': isDone});
    } catch (e) {
      throw Exception('Could not update the task: $e');
    }
  }

  static Future<void> editTask({
    required String docId,
    required String title,
    required String description,
    required DateTime time,
  }) async {
    try {
      await tasksCollection.doc(docId).update({
        'title': title,
        'description': description,
        'time': Timestamp.fromDate(time),
      });
    } catch (e) {
      throw Exception('Could not edit the task: $e');
    }
  }

  static Future<void> deleteTask(String docId) async {
    try {
      await tasksCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Could not delete the task: $e');
    }
  }

  static Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  static Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  static Future<User?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  static Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
  }

  static String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters).';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'network-request-failed':
        return 'Network error, please check your connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
