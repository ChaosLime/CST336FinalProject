$(document).ready(function(){
    
    $("#searchBtnMain").on("click", function(){
        var color = $("#shoeColor").val();
        var gender = genderCheck();
        var styles = $("#shoeStyle").val();
        var size = $("#shoeSizes").val();
        var action = "loadProduct";
        
        //No longer storing the results as a var and passing to renderProduct.
        //It seems that this was an issue with getting the data successfully to
        //the renderProduct function.
        //var results = updateSearch(color, gender, styles, action);
        updateSearch(color, gender, styles, size, action);
        
        //console.log(results);
        //renderProduct(results);
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
        //console.log(data);
        if(data.length == 0 || data == ''){
           alert('Search Not Found.');
        }else{
            /*
             *Below the object from the database is an array of arrays which contain
             * all the contents of the inventory by search results. 
             * the full results can be seen within console.dir(obj[0][i]) .
             * calling the first list and looking through each object within it allows
             * for each product to be instanciated with its own elements
                 */
            var obj = JSON.parse(data);

            for(var i = 0; i < obj[0].length; i++){
                console.dir(obj[0][i]); // intended to show the whole array of the search terms.
   
                document.getElementById("productImage").innerHTML = "<img src='/img/inventory/" + obj[0][i].image_path +"\'>";
                document.getElementById("model").innerHTML = "Model: "+ obj[0][i].model; 
                document.getElementById("color").innerHTML = "Color: " + obj[0][i].color_description;
                document.getElementById("type").innerHTML = "Type: " + obj[0][i].type_description;
                document.getElementById("sizeAndGender").innerHTML = "Size: " + obj[0][i].size + " " + obj[0][i].gender;
                document.getElementById("descriptionShort").innerHTML = "Short:" + obj[0][i].model_description;
                document.getElementById("descriptionLong").innerHTML = "Long: " + obj[0][i].model_detailed_description;
                document.getElementById("price").innerHTML = "Price: $" + obj[0][i].price;
                document.getElementById("quantityOnHand").innerHTML = "Qty: " + obj[0][i].quantity_on_hand;
                document.getElementById("addToCartBtn").innerHTML = "<button id='btn-add' class='btn btn-primary' type='button'>Add to Cart</button>";

                }
                
        }
    }
          

});




