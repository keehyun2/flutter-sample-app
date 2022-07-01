import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/infra/helpers/logger.dart';
import 'package:test_app/infra/helpers/validator.dart';
import 'package:test_app/module/login/controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = AuthController.to;

  /// 기본코드 +82(한국)
  String _dialCode = '+82';

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _emailKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  /// 스트립 구독.. dispose 할때 cancel 해주어야함.. 안하면 계속 중복실행됨.
  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  void initDynamicLinks() {
    _streamSubscription = authController.dynamicLinks.onLink.listen((dynamicLinkData) {
      log.i('FirebaseDynamicLinks 리스너 실행됨.');
      authController.loginWithEmailLink(_emailController.text, dynamicLinkData.link);
    }, onError: (error) => log.e(error.toString()));
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _smsController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const SizedBox(
                  height: 50.0,
                ),
                const TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: '문자'),
                    Tab(text: '메일'),
                    Tab(text: '외부연동'),
                  ],
                ),
                SizedBox(
                  height: 400.0,
                  child: TabBarView(
                    children: [
                      _phoneTab(),
                      _emailTab(),
                      _externalTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 이메일 탭
  Widget _emailTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Form(
            key: _emailKey,
            child: TextFormField(
              controller: _emailController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => Validator.email(value),
              decoration: const InputDecoration(hintText: 'Email'),
            ),
          ),
          Form(
            key: _passwordKey,
            child: TextFormField(
              decoration: const InputDecoration(hintText: 'Password'),
              controller: _passwordController,
              validator: (value) => Validator.password(value),
              obscureText: true,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (_emailKey.currentState!.validate() && _passwordKey.currentState!.validate()) {
                authController.registerEmail(_emailController.text.trim(), _passwordController.text.trim());
              }
            },
            child: const Text('Sign Up'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_emailKey.currentState!.validate() && _passwordKey.currentState!.validate()) {
                authController.loginEmailAndPassword(_emailController.text.trim(), _passwordController.text.trim());
              }
            },
            child: const Text('Login'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_emailKey.currentState!.validate()) {
                authController.sendPasswordResetEmail(_emailController.text.trim());
              }
            },
            child: const Text('send password reset email'),
          ),
          ElevatedButton(
            child: const Text('signInWithEmailAndLink'),
            onPressed: () async {
              if (_emailKey.currentState!.validate()) {
                authController.sendSignInLinkToEmail(_emailController.text.trim());
              }
            },
          )
        ],
      ),
    );
  }

  /// 외부 로그인(google, kakao) 탭
  Widget _externalTab() {
    return Column(
      children: [
        const SizedBox(
          height: 20.0,
        ),
        ElevatedButton(
          child: const Text('google login'),
          onPressed: () {
            authController.signInWithGoogle();
          },
        ),ElevatedButton(
          child: const Text('google clone'),
          onPressed: () {
            Get.toNamed('/test01');
          },
        ),
        // ElevatedButton(
        //   child: const Text('kakao login'),
        //   onPressed: () async {
        //     loginController.signInWithGoogle();
        //   },
        // ),
      ],
    );
  }

  /// 전화 sms 로그인 탭
  Widget _phoneTab() {
    return Column(
      children: [
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            CountryCodePicker(
              onChanged: (code) {
                setState(() {
                  _dialCode = code.dialCode!;
                });
              },
              initialSelection: _dialCode,
              favorite: const ['+82', 'KO'],
              countryFilter: const ['KR', 'US'],
              showFlagDialog: true,
              comparator: (a, b) => b.name?.compareTo(a.name ?? '') ?? 0,
              onInit: (code) => _dialCode = code?.dialCode ?? '',
            ),
            Flexible(
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone number(xxx-xxxx-xxxx)'),
              ),
            ),
          ],
        ),
        ElevatedButton(
          child: const Text('Verify Number'),
          onPressed: () {
            log.i('📞 $_dialCode ${_phoneNumberController.text.trim()}');
            authController.verifyPhoneNumber(
              _dialCode,
              _phoneNumberController.text.trim(),
            );
          },
        ),
        TextFormField(
          keyboardType: TextInputType.phone,
          controller: _smsController,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'Verification code'),
        ),
        ElevatedButton(
          child: const Text('Sign in'),
          onPressed: () {
            authController.signInWithPhoneNumber(_smsController.text.trim());
          },
        ),
      ],
    );
  }
}
