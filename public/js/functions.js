$(document).ready(function(){
    var turnCounter = 0;
    //intended to load the page with all content at the beginning, if removed will start blank.
    updateSearch("","W",-1,"4","loadProduct");
    
    $("#searchBtnMain").on("click", function(){
        var color = $("#shoeColor").val();
        var gender = genderCheck();
        var styles = $("#shoeStyle").val();
        var size = $("#shoeSizes").val();
        var action = "loadProduct";
        
        updateSearch(color, gender, styles, size, action);

    });

    $("#add-Btn").on("click", function(){
       alert("button pressed for add.");
    });


    function genderCheck(){
        //checks if both checkboxes are on
       if($("input[name='genderW']:checked").val() == 'W' &&
        $("input[name='genderM']:checked").val() == 'M'){
            //alert("Both M and W");
            return "";
        }
        else if( $("input[name='genderM']:checked").val() == 'M' && 
            $("input[name='genderW']:checked").val() != 'W'){
                return "M";
        }
        else if( $("input[name='genderW']:checked").val() == 'W' && 
            $("input[name='genderM']:checked").val() != 'M'){
                return "W";
        }
        else{
            return "";
        }
    }
   function updateSearch(color, gender, styles, size, action){
    $.ajax({
            method: "GET",
               url: "db/displayInventory",
              data: {color : color,
                      gender : gender,
                        styles: styles,
                        size: size,
                        action: action
                    },
                    success: function(data){
                        //When the ajax call is successful, call renderProduct
                        //here instead of returning it. Once it gets returned it
                        //seesm to not be useable anymore.
                        renderProduct(data);
                        //return data;
                    },
                    error: function(errorThrown){
                        //This seems to be the alert that keeps popping up 
                        //I am going to change it to be informative.
                        //alert(errorThrown.text);
                        alert("Error in updateSearch function within function.js");
                    }
            
        });//ajax
    }
    
    function insertIntoCart(username, sequence, quantity_in_cart, inv_qty_model, 
                    inv_qty_color_code, inv_qty_size, inv_qty_gender,action){
    $.ajax({
            method: "GET",
               url: "db/insertIntoCart",
              data: {username : username,
                     sequence : sequence,
                     quantity_in_cart: quantity_in_cart,
                     inventory_quantities_inventory_model: inv_qty_model,
                     inventory_quantities_color_color_code : inv_qty_color_code,
                     inventory_quantities_size : inv_qty_size,
                     inventory_quantities_gender : inv_qty_gender,
                     action: action
                    },
                    success: function(data){
                        alert("product inserted to cart");
                    },
                    error: function(errorThrown){
                        //This seems to be the alert that keeps popping up 
                        //I am going to change it to be informative.
                        //alert(errorThrown.text);
                        alert("Error in insertIntoCart function within function.js");
                    }
            
        });//ajax
    }
    

    function renderProduct(data){
        var obj = JSON.parse(data);
        var lengthOfElementsDisplayed = obj[0].length;

        if ( turnCounter % 2 == 0) {
            turnCounter = turnCounter + 1;
            $("#productContainer").empty();

        }else{
            turnCounter = turnCounter + 1;
            $("#productContainer").empty();

        }

         /* 
         *Below the object from the database is an array of arrays which contain
         * all the contents of the inventory by search results. 
         * the full results can be seen within console.dir(obj[0][i]) .
         * calling the first list and looking through each object within it allows
         * for each product to be instanciated with its own elements
         */
            
           
         

            $("#resultsFound").html("Results Found: " + lengthOfElementsDisplayed)
             for(var i = 0; i < lengthOfElementsDisplayed; i++)
             {
                $("#productContainer").append("<div id='product"+[i]+"'class='container canvas'></div>");
              
                //sets product id with tag elements
                $("#product" +[i]).html("<div class='image' id='productImage"+[i]+"'></div>");
                $("#product" +[i]).append("<h2 class='properties' id='model"+[i]+"'></h2>");
                $("#product" +[i]).append("<h3 id='color"+[i]+"'></h3>");
                $("#product" +[i]).append("<h3 id='type"+[i]+"'></h3>");
                $("#product" +[i]).append("<div class='description' id='descriptionShort"+[i]+"'></div>");
                $("#product" +[i]).append("<h4 id='sizeAndGender"+[i]+"'></h4>");
                $("#product" +[i]).append("<div class='price' id='price"+[i]+"'></div>");
                $("#product" +[i]).append("<div class='description' id='descriptionLong"+[i]+"'></div>");
                $("#product" +[i]).append("<div class='QOH' id='quantityOnHand"+[i]+"'></div>");
                $("#product" +[i]).append("<form id='productInput'><input class='quantityForOrder' id='productQuantity"+[i]+" type='number' min='1' value='1'>");
                $("#product" +[i]).append("<div class='addBtn' id='addToCartBtn"+[i]+"'></div></form>");

                    
                //fills tag elements
                $("#productImage"+[i]).append( "<img id='imageContainer' src='/img/inventory/" + obj[0][i].image_path +"\'>");
                $("#model"+[i]).append( "Model: "+ obj[0][i].model);
                $("#color"+[i]).append("Color: " + obj[0][i].color_description );
                $("#type"+[i]).append( "Type: " + obj[0][i].type_description);
                $("#sizeAndGender"+[i]).append( "Size: " + obj[0][i].size + " " + obj[0][i].gender);
                $("#descriptionShort"+[i]).append(obj[0][i].model_description );
                $("#descriptionLong"+[i]).append(obj[0][i].model_detailed_description);
                $("#price"+[i]).append( "Price: $" + obj[0][i].price);
                $("#quantityOnHand"+[i]).append( "Quantity Available: <span id='QuantityAvailable'>" + obj[0][i].quantity_on_hand + "</span>");
                $("#addToCartBtn"+[i]).append( "<button id='add-btn' class='btn btn-primary' type='button' value='"+[i]+"'>Add to Cart</button>");    
            }
        }// end of renderProduct


});




