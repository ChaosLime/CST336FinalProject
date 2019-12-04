$(document).ready(function(){
    
    $("#searchBtnMain").on("click", function(){
        var color = $("#shoeColor").val();
        var gender = genderCheck();
        var styles = $("#shoeStyle").val();
        var action = "loadProduct";
        updateSearch(color, gender, styles, action);
        
        renderProduct();
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
   
  

});



function updateSearch(color, gender, styles, action){
        $.ajax({
            method: "GET",
               url: "db/displayInventory",
               dataType: "json",
              data: {"color" : color,
                      "gender" : gender,
                        "styles": styles,
                        "action": action
                    }
        });//ajax
}

function renderProduct(){
   // $("#product").load("partials/product.ejs");
   $("#productImage").html("<img src='./img/testShoe.jpg'/>");
   $("#model").html("");
   $("#description").html("description");
   $("#price").html("price");
   $("#slider").html("<form action='submitToCart()'>"+
                     "<div class='slidecontainer'> " +
                        "<input type='range' min='5' max='13' value='9' class='slider' id='myRange'>"+
                        "<div>Size <span id='shoeSizeVal'></span><span id='gender'></span></div>" +
                     "</div>" +
                        "<label>Qty: </label>" +
                        "<input id='productQty' class='col-md-3' type='number' min='1' value='1'> "+
                        "<button id='btn-add' class='btn btn-primary' type='button'>Add to Cart</button> "+
                     "</form>" +
                     "<script>" +
                     "var slider = document.getElementById('myRange'); "+
                     "var output = document.getElementById('shoeSizeVal'); "+
                     "output.innerHTML = slider.value; "+
                     "slider.oninput = function() { " +
                     "output.innerHTML = this.value; }; "+
                    "</script> ");
   


}
