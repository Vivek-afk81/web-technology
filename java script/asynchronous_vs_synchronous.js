function orderFood(callbacks){
    console.log("Ordering food...");
    setTimeout(function(){
        console.log("Food is ready!");
        callbacks();
    }, 2000);
}

function eatFood(){
    console.log("Eating food...");
}

orderFood(eatFood);