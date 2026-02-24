// key points about const in JavaScript
//1. no redeclaration within the same scope
//2. block scope
//3. must be initialized during declaration
//4. value cannot be changed (immutable binding)


const arr=[1,2,3,"hello"];
arr.push(4); // allowed, modifying the contents of the array
console.log(arr); // Output: [1, 2, 3, "hello", 4]  

arr=[5,6,7]; // TypeError: Assignment to constant variable. 
console.log(arr);