import 'dart:io';


void main(){
    stdout.write('Enter your name: ');
    String? name = stdin.readLineSync();
    print('Hello, $name!');
}
// void main(){
//     int a= 10;
//     int b=67;

//     print("${a+b} ${a-b} ${a/b}");
// }

// How to take user input