function user(name,age){
    this.name=name;
    this.age=age;
    this.address={
        city: 'New York',
        country: 'USA'  
    };
}

console.log(user1.address.city); // New York

let book2=book


//value can be duplicated but keys must be unique






let person={
    name:'John',
    age:30,
    isemployed:true,
    greet:function(){
        console.log('Hello, my name is ' + this.name);
        console.log(this);
        let innergreet=function(){
            console.log('Hello, my name is ' + this.name);
            console.log(this);
        }
        innergreet();
    }
};
person.greet();


 Array.prototype.forEach=function(callback){
    for(let i=0;i<this.length;i++){
        callback(this[i],i,this);
    }       