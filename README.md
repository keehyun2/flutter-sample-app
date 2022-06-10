# TEST
- android 만 테스트함.

1. `firebase` 연동하여 로그인 구현.
전화인증(문자), 이메일, 구글 로그인

2. `firestore` db 연동하여 채팅 구현

- firebase 프로젝트가 spark 요금제여서 문자 50개 제한 있음. 
- google cloud project 도 결제 계정 연동 안되 있음.(map api)

3. M1 cpu IOS 빌드 실패시
```shell
rm pubspec.lock
cd ios/
rm -rf Pods
rm Podfile.lock
arch -x86_64 pod cache clean --all
cd ..
flutter clean
flutter pub get
cd ios/
arch -x86_64 pod install
```

4. api key 보안
- android : key.properties 에 보관
- ios : Release.xcconfig , Debug.xcconfig 에 보관
