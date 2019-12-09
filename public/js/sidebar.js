$(document).ready(function () {
    var sideActive = false;
    var isProductAdded = false;           

    $('#sidebarCollapse').on('click', function () {
        if(isProductAdded){
            if(!sideActive){
            sideActive = true;
            $('#sidebar').toggleClass('active');
            $(this).toggleClass('active');
            }
            else if(sideActive){
                sideActive = false;
                $('#sidebar').toggleClass('active');
                $(this).toggleClass('active');
            }
        }
        else {
              alert("Please add items to cart before viewing.");

        }
    });
    
    let alreadyAdded = false;
    $('.add-Btn').on('click', function () {
        if(!sideActive){
            if(!alreadyAdded){
                sideActive = true;
            $('#sidebar').toggleClass('active');
            $(this).toggleClass('active');
            isProductAdded = true;
            console.log("add product to cart.");
            addToCart("1");
            alreadyAdded = true;
            }
            else{
                  alert("Already in cart, please review in Checkout.");
            }
            
        }
        else{
            alert("Already in cart, please review in Checkout.");
        }
     });

    function addToCart(x){
        if(x == 1){
            //document.getElementById("productInCart").innerHTML='<img src="./img/testShoe.jpg"/>';
        //document.getElementById("quantity").innerHTML=
        //quantity;
        }
        else {
            alert("product not added to cart");
        }

    }
    
    $('#toCartBtn').on('click',function(){
       var isLoggedIn = false;
           if(!isLoggedIn){
               alert("Not logged in. You will be redirected to the Sign In page.");
           }
 
    });

    
    
});