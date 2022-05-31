import 'dart:io';

Future<String> download(){
// Future는 빈박스이다.
// 먼저 value는 빈박스(null)를 만들고 5초뒤 return을 받음
  Future<String> value = Future.delayed(Duration(seconds:5),(){
    return '사과'; // 5초뒤에 return을 받음
  });
  return value; // Futurn data는 Future로 받아야함
}

// 첫번째 방법
// await를 사용하기 때문에 async 키워드 필요
// main() async {
//   //빈박스를 먼저 받아오기 때문에 Future로 받아야함
//   //그렇기에 기다릴 필요가 있음 -> await 사용 -> async 키워드 필요
//   // Future<String> value = download();
//   // 기다렸다 받기 때문에 Future로 받을 필요없음
//   String value = await download();
//   print(value);
// }

// 두번째 방법
main(){
  download().then((value){
    // 빈박스가 채워져야 실행됨
    print(value);
  });
//메인 종료 후 download return 받음
}