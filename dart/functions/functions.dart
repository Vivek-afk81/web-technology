import 'dart:async';

// 0. Type alias (typedef) — makes function types readable
typedef Operation = int Function(int a, int b);

// 1. Basic function (no return value)
void greet() {
  print('Hello, Dart!');
}

// 2. Function with return type
int add(int a, int b) {
  return a + b;
}

// 3. Arrow (fat-arrow) function — for single-expression bodies
int square(int n) => n * n;

// 4. Optional positional parameters: use [] (good for short, ordered extras)
void greetUser(String name, [String? title]) {
  if (title != null && title.isNotEmpty) {
    print('Hello $title $name');
  } else {
    print('Hello $name');
  }
}

// 5. Named optional parameters: use {} (clear, self-documenting)
//    Prefer named params when there are multiple optional values.
void displayInfo({String? name, int? age}) {
  // Show friendly defaults when values are null
  print('Name: ${name ?? "unknown"}, Age: ${age?.toString() ?? "unknown"}');
}

// 6. Required named parameters (useful to force callers to pass important values)
void registerUser({required String username, required String email}) {
  print('Registered user -> username: $username, email: $email');
}

// 7. Default parameter values (works for named and optional positional)
void countryInfo(String name, {String country = 'India'}) {
  print('$name is from $country');
}

// 8. Anonymous function (lambda) — useful as a value
void anonymousExample() {
  // store a function in a variable
  var multiply = (int a, int b) {
    return a * b;
  };
  print('Multiply: ${multiply(4, 5)}');

  // shorter with arrow
  var div = (int a, int b) => (b == 0 ? 0 : a ~/ b);
  print('Divide (int): ${div(9, 3)}');
}

// 9. Higher-order function — take other functions as arguments
void operate(int a, int b, Operation operation) {
  print('operate result: ${operation(a, b)}');
}

// 10. Function returning a function (closure) — returned function captures outer state
Function makePrinter(String prefix) {
  // returned function "remembers" prefix
  return (String message) => print('$prefix: $message');
}

// A numeric closure: returns a function that adds `x` to its argument
int Function(int) makeAdder(int x) {
  return (int y) => x + y; // closure captures x
}

// 11. Recursion — function calling itself (classic example: factorial)
int factorial(int n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

// 12. Typedef usage — we already declared Operation above
int subtract(int a, int b) => a - b;

// 13. Async function (Future) with simple error handling
Future<String> fetchData() async {
  try {
    // simulate network / long-running work
    await Future.delayed(const Duration(seconds: 2));
    return 'Data fetched successfully!';
  } catch (e) {
    return 'Fetch error: $e';
  }
}

// MAIN
Future<void> main() async {
  print('--- Basic function ---');
  greet();

  print('\n--- Return value ---');
  print('Addition (10 + 20): ${add(10, 20)}');

  print('\n--- Arrow function ---');
  print('Square of 6: ${square(6)}');

  print('\n--- Optional positional params ---');
  greetUser('Vivek');
  greetUser('Vivek', 'Er.');

  print('\n--- Named optional params ---');
  displayInfo(name: 'Rahul', age: 25);
  displayInfo(); // shows defaults

  print('\n--- Required named params ---');
  registerUser(username: 'coder123', email: 'coder@gmail.com');

  print('\n--- Default parameter value ---');
  countryInfo('Amit');
  countryInfo('John', country: 'USA');

  print('\n--- Anonymous functions ---');
  anonymousExample();

  print('\n--- Higher-order functions ---');
  operate(10, 5, add);       // pass named function
  operate(10, 5, subtract);  // pass another named function
  // pass an anonymous function directly
  operate(10, 5, (int x, int y) => x * y);

  print('\n--- Function returning function / closures ---');
  var warn = makePrinter('Warning'); // returns a function
  warn('Low battery');

  var addFive = makeAdder(5);
  print('5 + 7 = ${addFive(7)}');

  print('\n--- Recursion ---');
  print('5! = ${factorial(5)}');

  print('\n--- Typedef example ---');
  Operation op = subtract; // using typedef makes code clearer
  print('Using typedef: ${op(20, 8)}');

  print('\n--- Async example ---');
  print('Fetching data...');
  final data = await fetchData();
  print(data);

  print('\n--- Small list + anonymous/arrow examples ---');
  final nums = [1, 2, 3, 4];
  // map with arrow function
  final squares = nums.map((n) => n * n).toList();
  print('Squares: $squares');

  // forEach with anonymous function
  nums.forEach((n) {
    // a quick inline function — great for small callbacks
    print('Number: $n');
  });
}