$(document).ready(function () {
    var sideActive = false;

    $('#sidebarCollapse').on('click', function () {
        
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
        

    });
    
    //used to dynamically allocate button presses to user
    let alreadyAdded = false;
    $('body').on('click','.cartBtn', function () {
        //returns unique value from button.

        if(!sideActive){
            if(!alreadyAdded){
               sideActive = true;
            $('#sidebar').toggleClass('active');
            $(this).toggleClass('active');
            alreadyAdded = true;
            }
        }
       addToCart($(this).val())
     });

    function addToCart(elementValue){
        //alert(elementValue);
        var username = 'generic';
        var model = $("#model"+elementValue).text();
        var size = $("#size"+elementValue).text();
        var color = $("#color_code"+elementValue).text();
        var gender =$("#gender"+elementValue).text();
        var qty = $("#productQuantity"+elementValue).val();

        //alert(username + " " + model + " " + size + " " + color + " " + gender + " " + qty);
        insertIntoCart(username, model, size, color, gender, qty);

    }

    function insertIntoCart(username, model, size, color, gender, qty){
    $.ajax({
            method: "GET",
               url: "db/insertIntoCart",
              data: {username : username,
                     inventory_quantities_inventory_model: model,
                     inventory_quantities_size : size,
                     inventory_quantities_color_color_code : color,
                     inventory_quantities_gender : gender,
                     quantity_in_cart: qty,

                     },
                    success: function(data){
                        //alert("product inserted to cart");
                        displayCart('generic');
                    },
                    error: function(errorThrown){

                        console.log("Error in insertIntoCart function within sidebar.js");
                    }
            
        });//ajax
    }
    
    function displayCart(username){
    $.ajax({
            method: "GET",
               url: "db/displayCart",
              data: {username : username},
                    success: function(data){
                        renderCart(data);
                    },
                    error: function(errorThrown){
                        console.log("Error in displayCart AJAX call within sidebar.js");
                    }
            
        });//ajax
    }

    function renderCart(data){
        var obj = JSON.parse(data);
        var lengthOfElementsDisplayed = obj[0].length;

/* 
         *Below the object from the database is an array of arrays which contain
         * all the contents of the inventory by search results. 
         * the full results can be seen within console.dir(obj[0][i]) .
         * calling the first list and looking through each object within it allows
         * for each product to be instanciated with its own elements
         */
            
        $("#amountInCart").html("Items In Cart: " + lengthOfElementsDisplayed);
         for(var i = 0; i < lengthOfElementsDisplayed; i++)
             {
                $("#productInCart").append("<div id='cart"+[i]+"'class='container'></div>");
              
                //sets product id with tag elements
                $("#cart" +[i]).html("<div class='image' id='productImage"+[i]+"'></div>");
                $("#cart" +[i]).append("<div>Model: <span id='model"+[i]+"'></span></div>");
                $("#cart" +[i]).append("<div>Color Code: <span id='color"+[i]+"'></span></div>");
                $("#cart" +[i]).append("<div>Size: <span id='size"+[i]+"'></span>" +
                            "<span id='gender"+[i]+"'></span></div>");
                $("#cart" +[i]).append("<div>Qty: <span id='qty"+[i]+"'></span></div>");



                //fills tag elements
                $("#productImage"+[i]).append("<img id='imageContainerSmall' src='/img/inventory/" + obj[0][i].image_path +"\'>");
                $("#model"+[i]).append(obj[0][i].inventory_quantities_inventory_model);
                $("#color"+[i]).append(obj[0][i].inventory_quantities_color_color_code);
                $("#size"+[i]).append(obj[0][i].inventory_quantities_size);
                $("#gender"+[i]).append(obj[0][i].inventory_quantities_gender);
                $("#qty"+[i]).append(obj[0][i].quantity_in_cart);

                
            }
            $("#checkoutBtn").html("<form action='./cart.html'>" +
          "<button  id='toCartBtn' class='btn btn-success' type='submit'>Checkout</button></form>");
    }
    
});