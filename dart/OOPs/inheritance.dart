// Parent class
class Animal {
  void eat() {
    print("Animal is eating");
  }
}

// Child class
class Dog extends Animal {
  void bark() {
    print("Dog is barking");
  }
}

void main() {
  Dog d = Dog();
  d.eat();   // Inherited method
  d.bark();  // Own method
}