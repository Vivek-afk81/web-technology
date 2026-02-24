// Demo Code 1.1
// let myLet =10;
// console.log(myLet);
// let myLet =20; // This will cause a SyntaxError: Identifier 'myLet' has already been declared

//Demo Code 1.2 :  re declaration example 2 - different block scope
// {
//     let x=50
//     console.log(x);
// }
// {
//     let x=100 // this is allowed as it is in a different block scope
//     console.log(x);
// }

// Demo Code 1.3 : redeclaration example 3 - directed nested scope
// {
// let x=50;
// console.log(x);
// {
//     let x=100; //uncaught SyntaxError: Identifier 'x' has already been declared
//     let y= 200; // this is allowed as it is a differnet identifier
//     console.log(x);
//     console.log(y);
// }
// }

// Demo Code 1.4 : redeclaration example 4 - nested block scope with if statement
{
let x=50;
console.log(x);
if(true){
    let x=100; // this is allowed as it is in a different block scope
    console.log(x);
}
console.log(x);
}


// 