$(document).ready(function () {
   var sideInactive = false;

    var fillCart = (function() {
        var executed = false;
        return function() {
            if (!executed) {
                executed = true;
                displayCart('generic');
            }
        };
    })();
    //auto fills cart on start, will only run once.
    fillCart();


    $('#sidebarCollapse').on('click', function () {

            if(!sideInactive){
                sideInactive = true;
                sessionStorage.setItem("sideInactive", true);
    
                $('#sidebar').toggleClass('active');
                $(this).toggleClass('active');
            }
            else if(sideInactive){
                sideInactive = false;
                sessionStorage.setItem("sideInactive", false);

                $('#sidebar').toggleClass('active');
                $(this).toggleClass('active');
            }

    });
    
    //used to dynamically allocate button presses to user
    $('body').on('click','.cartBtn', function () {
        if(!sideInactive){
                sideInactive = false;
                $('#sidebar').toggleClass('active');
                $(this).toggleClass('active');
        }
        addToCart($(this).val())
    });



    function addToCart(elementValue){
        var username = 'generic';
        var model = $("#model"+elementValue).text();
        var size = $("#size"+elementValue).text();
        var color = $("#color_code"+elementValue).text();
        var gender =$("#gender"+elementValue).text();
        var qty = $("#productQuantity"+elementValue).val();

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
                $("#cart" +[i]).html("<div id='productImageCart"+[i]+"'></div>");
                $("#cart" +[i]).append("<div>Model: <span id='modelCart"+[i]+"'></span></div>");
                $("#cart" +[i]).append("<div>Color Code: <span id='colorCart"+[i]+"'></span></div>");
                $("#cart" +[i]).append("<div>Size: <span id='sizeCart"+[i]+"'></span>" +
                            "<span id='genderCart"+[i]+"'></span></div>");
                $("#cart" +[i]).append("<div>Qty: <span id='qtyCart"+[i]+"'></span></div>");



                //fills tag elements
                $("#productImageCart"+[i]).append("<img id='imageContainerSmall' src='/img/inventory/" + obj[0][i].image_path +"\'>");
                $("#modelCart"+[i]).append(obj[0][i].inventory_quantities_inventory_model);
                $("#colorCart"+[i]).append(obj[0][i].inventory_quantities_color_color_code);
                $("#sizeCart"+[i]).append(obj[0][i].inventory_quantities_size);
                $("#genderCart"+[i]).append(obj[0][i].inventory_quantities_gender);
                $("#qtyCart"+[i]).append(obj[0][i].quantity_in_cart);

                
            }
            $("#checkoutBtn").html("<form action='./cart.html'>" +
          "<button  id='toCartBtn' class='btn btn-success' type='submit'>Checkout</button></form>");
    }
    
});