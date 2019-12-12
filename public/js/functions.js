$(document).ready(function(){
    var turnCounter = 0;
    //intended to load the page with all content at the beginning, if removed will start blank.
    updateSearch("","",-1,"","loadProduct");

    $("#searchBtnMain").on("click", function(){
        var color = $("#shoeColor").val();
        var gender = genderCheck();
        var styles = $("#shoeStyle").val();
        var size = $("#shoeSizes").val();
        var action = "loadProduct";

        
        updateSearch(color, gender, styles, size, action);

    
    });
    
    $("#amountInCart").html("Empty");


    function genderCheck(){
        //checks if both checkboxes are on
       if($("input[name='genderW']:checked").val() == 'W' &&
        $("input[name='genderM']:checked").val() == 'M'){
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
   function updateSearch(color, gender, styles, size){
    $.ajax({
            method: "GET",
               url: "db/displayInventory",
              data: {color : color,
                      gender : gender,
                        styles: styles,
                        size: size
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
                        console.log("Error in updateSearch function within function.js");
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
                $("#product" +[i]).append("<h2>Model: <span class='properties' id='model"+[i]+"'></span></h2>");
                $("#product" +[i]).append("<h3>Color: <span id='color"+[i]+"'></span></h3>");
                $("#product" +[i]).append("<span id='color_code"+[i]+"' class='d-none'></span>");
                $("#product" +[i]).append("<h3>Type:<span id='type"+[i]+"'></span></h3>");
                $("#product" +[i]).append("<div class='description' id='descriptionShort"+[i]+"'></div>");
                $("#product" +[i]).append("<h4>Size: <span id='size"+[i]+"'></span><span id='gender"+[i]+"'></span></h4>");
                $("#product" +[i]).append("<div>Price: <span class='price' id='price"+[i]+"'>$</span></div>");
                $("#product" +[i]).append("<div class='description' id='descriptionLong"+[i]+"'></div>");
                $("#product" +[i]).append("<div id='QuantityAvailable'>Quantity Available: <span class='QOH' id='quantityOnHand"+[i]+"'></span></div>");
                $("#product" +[i]).append("<form id='productInput'><input class='quantityForOrder' id='productQuantity"+[i]+"' type='number' min='1' value='1'>");
                
                $("#product" +[i]).append("<div class='addBtn' id='addToCartBtn"+[i]+"'></div></form>");

                    
                //fills tag elements
                $("#productImage"+[i]).append("<img id='imageContainer' src='/img/inventory/" + obj[0][i].image_path +"\'>");
                $("#model"+[i]).append(obj[0][i].model);
                $("#color"+[i]).append(obj[0][i].color_description);
                $("#color_code"+[i]).append(obj[0][i].color_code);
                $("#type"+[i]).append(obj[0][i].type_description);
                $("#size"+[i]).append(obj[0][i].size);
                $("#gender"+[i]).append(obj[0][i].gender);
                $("#descriptionShort"+[i]).append(obj[0][i].model_description );
                $("#descriptionLong"+[i]).append(obj[0][i].model_detailed_description);
                $("#price"+[i]).append(obj[0][i].price);
                    if(obj[0][i].quantity_on_hand < 0){
                        var qty = 0;
                    }else{
                        qty = obj[0][i].quantity_on_hand;}
                $("#quantityOnHand"+[i]).append(qty);
                $("#addToCartBtn"+[i]).append( "<button id='add-btn"+[i]+"' class='btn btn-primary cartBtn' type='button' value='"+[i]+"'>Add to Cart</button>");    
            }
        }// end of renderProduct


});




