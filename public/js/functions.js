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
        if(data.length == 0 || data == ''){
           alert('Search Not Found.');
        }else{
            var obj = JSON.parse(data);

        }

        document.getElementById("productImage").innerHTML = "<img src='/img/inventory/" + obj.image_path +"\'>";
        document.getElementById("model").innerHTML = "Model: "+ obj.model; 
        document.getElementById("color").innerHTML = "Color: " + obj.color_description;
        document.getElementById("type").innerHTML = "Type: " + obj.type_description;
        document.getElementById("sizeAndGender").innerHTML = "Size: " + obj.size + " " + obj.gender;
        document.getElementById("descriptionShort").innerHTML = "Short:" + obj.model_description;
        document.getElementById("descriptionLong").innerHTML = "Long: " + obj.model_detailed_description;
        document.getElementById("price").innerHTML = "Price: $" + obj.price;
        document.getElementById("quantityOnHand").innerHTML = "Qty: " + obj.quantity_on_hand;
        document.getElementById("addToCartBtn").innerHTML = "<button id='btn-add' class='btn btn-primary' type='button'>Add to Cart</button>";
        }
          

});




