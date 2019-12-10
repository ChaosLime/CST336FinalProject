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
    
    //used to dynamically allocate button presses to user
    let alreadyAdded = false;
    $('body').on('click','#add-btn', function () {
        alert($("#add-btn").val());
        if(!sideActive){
            if(!alreadyAdded){
                sideActive = true;
            $('#sidebar').toggleClass('active');
            $(this).toggleClass('active');
            isProductAdded = true;
            //console.log("add product to cart.");
            var x = 1;
            addToCart(x);
            alreadyAdded = true;
            }

        }
        else{
            alert("Already in cart, please review in Checkout.");
        }
     });

    function addToCart(x){
        $("#productInCart").html("Product  added " + x)
        //should call insert query to cart to add unique product

    }
    
    $('#toCartBtn').on('click',function(){
       var isLoggedIn = false;
           if(!isLoggedIn){
               alert("Not logged in. You will be redirected to the Sign In page.");
           }
 
    });

    
    
});