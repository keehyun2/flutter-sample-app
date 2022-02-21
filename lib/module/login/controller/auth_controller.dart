import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_app/infra/constants/collection.dart';
import 'package:test_app/infra/constants/globals.dart';
import 'package:test_app/infra/helpers/logger.dart';
import 'package:test_app/module/chat/model/user_chat.dart';

class AuthController extends GetxController {
  static AuthController to = Get.find();
  final FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final firebaseUser = Rxn<User>();

  final userChatRef = FirebaseFirestore.instance.collection(Collection.users).withConverter<UserChat>(
        fromFirestore: (snapshots, _) => UserChat.fromJson(snapshots.data()!),
        toFirestore: (userChat, _) => userChat.toJson(),
      );

  late String _verificationId; // 인증요청할때 마다 변함. 이것과 인증번호를 보내서 인증함

  /// Firebase user one-time fetch
  User? get getUser => _auth.currentUser;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final getStorage = GetStorage();

  @override
  void onReady() {
    super.onReady();

    firebaseUser.bindStream(_auth.authStateChanges());

    /// 워커-앱 실행중에 계속 돌아가는듯?
    ever(firebaseUser, _setInitialScreen);
  }

  /// 파이어베이스 로그인 여부체크
  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      showSnackbar('sign in', 'Successfully signed in : $user');

      /// db 저장
      _saveUser(user);
      Get.offAllNamed('/home');
    }
  }

  /// user 정보 firestore db 에 저장하고 getStorage 에도 저장
  void _saveUser(User user) async {
    // final users = await userChatRef.where(Globals.id, isEqualTo: user.uid).get();
    // final documents = users.docs;

    // if (documents.isEmpty) {
      // Writing data to server because here is a new user
      fireStore.collection(Collection.users).doc(user.uid).set({
        Globals.id: user.uid,
        Globals.nickname: user.displayName,
        Globals.photoUrl: user.photoURL,
        Globals.chattingWith: null,
        Globals.phoneNumber: user.phoneNumber,
        'emailVerified' : user.emailVerified,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    // } else {
    //   // Already sign up, just get data from firestore
    //   UserChat userChat = documents.first.data();
    // }
  }

  /// 전화번호 sms 인증(숫자 6자리 보내기)
  void verifyPhoneNumber(String countryDialCode, String phoneNumber) async {
    PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);
      showSnackbar('signed in', 'Phone number automatically verified and user signed in: ${_auth.currentUser?.uid}');
    };

    PhoneVerificationFailed verificationFailed = (FirebaseAuthException authException) {
      showSnackbar('verification failed', 'aPhone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };

    PhoneCodeSent codeSent = (String verificationId, int? forceResendingToken) async {
      _verificationId = verificationId;
      showSnackbar('verifyPhoneNumber', 'Please check your phone for the verification code.');
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
      _verificationId = verificationId;
    };

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: countryDialCode + phoneNumber,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      showSnackbar('verifyPhoneNumber', 'Failed to Verify Phone Number: $e');
    }
  }

  /// show 스낵바(알림창)
  void showSnackbar(String title, String msg) {
    Get.snackbar(title, msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 10),
        backgroundColor: Get.theme.snackBarTheme.backgroundColor,
        colorText: Get.theme.snackBarTheme.actionTextColor);
  }

  /// 전화번호 인증: verificationId, smsCode 로 인증
  void signInWithPhoneNumber(String smsCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      // final User? user = (await _auth.signInWithCredential(credential)).user;
      // showSnackbar('signInWithPhoneNumber', 'Successfully signed in : $user');
    } catch (e) {
      showSnackbar('signInWithPhoneNumber', 'Failed to sign in: ' + e.toString());
    }
  }

  /// 구글로 signIn
  void signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth?.idToken,
      accessToken: googleAuth?.accessToken,
    );
    await _auth.signInWithCredential(credential);
    // final User? user = (await _auth.signInWithCredential(credential)).user;
    // showSnackbar('signInWithGoogle', 'Successfully signed in : $user');
  }

  /// 이메일 등록(등록과 동시에 바로 로그인)
  void registerEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (firebaseAuthException) {
      showSnackbar('registerEmail', 'Failed to register: ' + firebaseAuthException.toString());
    }
  }

  /// 이메일 로그인
  void loginEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (firebaseAuthException) {
      showSnackbar('loginEmailAndPassword', 'Failed to sign in: ' + firebaseAuthException.toString());
    }
  }

  /// 비밀번호 재설정 이메일 보내기
  void sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showSnackbar('sendPasswordResetEmail', '$email 로 메일을 발송하였습니다.');
    } catch (firebaseAuthException) {
      showSnackbar('sendPasswordResetEmail', 'Failed to send email: ' + firebaseAuthException.toString());
    }
  }

  /// 로그인 링크 있는 메일 보내기
  void sendSignInLinkToEmail(String email) async {
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
          url: 'https://keehyun2.page.link/',
          handleCodeInApp: true,
          iOSBundleId: 'com.keehyun2.test',
          androidPackageName: 'com.keehyun2.test',
          androidInstallApp: true,
          androidMinimumVersion: '1'),
    );
    showSnackbar('sendSignInLinkToEmail', '$email 로 메일을 발송하였습니다.');
  }

  void loginWithEmailLink(String email, Uri? link) async {
    log.i('email: $email, link: $link');
    await _auth.signInWithEmailLink(
      email: email,
      emailLink: link.toString(),
    );
  }

  /// Sign out
  signOut() {
    _googleSignIn.signOut();
    _auth.signOut();
    showSnackbar('signOut', 'signOut');
  }
}
