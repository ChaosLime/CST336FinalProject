$(document).ready(function(){
    
    $("#searchBtnMain").on("click", function(){
        var color = $("#shoeColor").val();
        var gender = genderCheck();
        var styles = $("#shoeStyle").val();
        var action = "loadProduct";
        var results = updateSearch(color, gender, styles, action);
        console.log(results);
        renderProduct(results);
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
   function updateSearch(color, gender, styles, action){
    $.ajax({
            method: "GET",
               url: "db/displayInventory",
              data: {color : color,
                      gender : gender,
                        styles: styles,
                        action: action
                    },
                    success: function(data){
                        if(!data.length){
                            alert("no length");
                        }
                        return data;
                    },
                    error: function(errorThrown){
                        alert(errorThrown);
                    }
            
        });//ajax
        }
        
        
        
        function renderProduct(results){
        
            $("#product").append(results);
            console.log("render now");
           //$("#product").load(results);
        
        
            //$("#product").html('<% include partials/product.ejs %>');
           $("#productImage").html("<img src='/img/inventory/mens/lifters/green.png' width='250' height='200'/>");
           $("#model").html("Test");
           $("#description").html("description");
           $("#price").html("price");
          
           $("#slider").html("<form action='submitToCart()'>"+
                             "<div class='slidecontainer'> " +
                                "<input type='range' min='5' max='13' value='9' class='slider' id='myRange'>"+
                                "<div>Size <span id='shoeSizeVal'></span><span id='gender'></span></div>" +
                             "</div>" +
                             "<script>" +
                             "var slider = document.getElementById('myRange'); "+
                             "var output = document.getElementById('shoeSizeVal'); "+
                             "output.innerHTML = slider.value; "+
                             "slider.oninput = function() { " +
                             "output.innerHTML = this.value; }; "+
                            "</script> ");
             $("#quantity").html("<label>Qty: </label>" +
                                "<input id='productQty' class='col-md-3' type='number' min='1' value='1'> ");                    
           
        
        
        }
          

});




