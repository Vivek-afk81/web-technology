class car {
    String brand = "Toyota";

    void drive() {
        print("car is driving")
    }
}

void main() {
  Car myCar = Car();
  print(myCar.brand);
  myCar.drive();
}