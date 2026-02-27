//method overloading
//not supported but can be achieved
//using optional parameters

// class Example {
//   void greet([String? name]) {
//     if (name != null) {
//       print("Hello $name");
//     } else {
//       print("Hello");
//     }
//   }
// }

// // using named parameters

// class Example {
//   void greet({String? name, int? age}) {
//     print("Name: $name, Age: $age");
//   }
// }

// void main() {
//   var obj = Example();
//   obj.greet();
//   obj.greet("John");
// }

//method overriding

class Animal {
  void sound() {
    print("Animal makes a sound");
  }
}

class Dog extends Animal {
  @override
  void sound() {
    print("Dog barks");
  }
}

void main() {
  Animal myAnimal = Dog();  // Parent reference
  myAnimal.sound();         // Dog barks (runtime polymorphism)
}