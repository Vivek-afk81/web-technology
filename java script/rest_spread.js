let arr1 =[1,2,3]
let arr2 =[...arr1,4,5]

// console.log(arr2)

arr2[0]=100

// console.log(arr1)
// console.log(arr2) // this is deep copy as arr1 did'nt change

arr2[2].name='jane' // ReferenceError: arr1 is not defined
console.log(arr1) // this is shallow copy as arr1 changed
console.log(arr2)