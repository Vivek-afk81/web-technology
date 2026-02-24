//anonymous function
//an anonymous function is a function that does not have a name and is often used as an argument to other functions or assigned to variables.
let multiply=function(a,b){
    return a*b;
};
console.log(multiply(5,6)); //30

//arrow function
//an arrow function is a more concise syntax for writing functions in JavaScript. It uses the "=>" syntax and does not have its own "this" context.
let divide=(a,b)=>{
    return a/b;
};
console.log(divide(30,5)); //6

//categories of arrow functions: based on parameters and body

//1. Based on parameters:
//a. No parameters+more than one parameter 