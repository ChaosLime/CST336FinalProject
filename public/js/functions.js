$(document).ready(function(){
    var turnCounter = 0;
    
    $("#searchBtnMain").on("click", function(){
        var color = $("#shoeColor").val();
        var gender = genderCheck();
        var styles = $("#shoeStyle").val();
        var size = $("#shoeSizes").val();
        var action = "loadProduct";
        
        updateSearch(color, gender, styles, size, action);

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
                $("#productContainer").append("<div id='product"+[i]+"'class='container'></div>");
              
                //sets product id with tag elements
                $("#product" +[i]).html("<div id='productImage"+[i]+"'></div>");
                $("#product" +[i]).append("<div id='model"+[i]+"'></div>");
                $("#product" +[i]).append("<div id='color"+[i]+"'></div>");
                $("#product" +[i]).append("<div id='type"+[i]+"'></div>");
                $("#product" +[i]).append("<div id='sizeAndGender"+[i]+"'></div>");
                $("#product" +[i]).append("<div id='descriptionShort"+[i]+"'></div>");
                $("#product" +[i]).append("<div id='descriptionLong"+[i]+"'></div>");
                $("#product" +[i]).append("<div id='price"+[i]+"'></div>");
                $("#product" +[i]).append("<div id='quantityOnHand"+[i]+"'></div>");
                $("#product" +[i]).append("<form><input id='productQuantity"+[i]+" type='number' min='1' value='1'>");
                $("#product" +[i]).append("<div id='addToCartBtn"+[i]+"'></div></form>");
                    
                //fills tag elements
                $("#productImage"+[i]).append( "<img src='/img/inventory/" + obj[0][i].image_path +"\'>");
                $("#model"+[i]).append( "Model: "+ obj[0][i].model);
                $("#color"+[i]).append("Color: " + obj[0][i].color_description );
                $("#type"+[i]).append( "Type: " + obj[0][i].type_description);
                $("#sizeAndGender"+[i]).append( "Size: " + obj[0][i].size + " " + obj[0][i].gender);
                $("#descriptionShort"+[i]).append( "Short:" + obj[0][i].model_description);
                $("#descriptionLong"+[i]).append( "Long: " + obj[0][i].model_detailed_description);
                $("#price"+[i]).append( "Price: $" + obj[0][i].price);
                $("#quantityOnHand"+[i]).append( "Qty: " + obj[0][i].quantity_on_hand);
                $("#addToCartBtn"+[i]).append( "<button id='add-btn' class='btn btn-primary' type='button'>Add to Cart</button>");    
            }
        }// end of renderProduct


});




