$(document).ready(function(){
   
       $("#ValButton").click( function(){
        var userInput = $("#UserInput").val();
        getValueAdmin(userInput);
    });

    
   function getValueAdmin(userInput){
    $.ajax({
            method: "GET",
               url: "db/getValuation",
              data: {userInput : userInput},
                    success: function(data){
                        renderVal(data);
                    },
                    error: function(errorThrown){
                        console.log("Error in getValueAdmin function within adminTools.js");
                    }
        });//ajax
    }
    
  
    function renderVal(data){
        var obj = JSON.parse(data);
        var lengthOfElementsDisplayed = obj[0].length;

        //alert(data);
        $("#valContainer").html("<div id='getval'></div>");

        if($("#UserInput").val() == 1){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
                {
                $("#getval").append("All Inventory: <br>$"+ obj[0][i].inventory_value +"<br>");
                }
        }
        
        else if($("#UserInput").val() == 2){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
                {
                $("#getval").append("Model: "+ obj[0][i].model +", Value: $"+ obj[0][i].inventory_value +"<br>");
                }
        }
        
        else if($("#UserInput").val() == 3){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
                {
                $("#getval").append(obj[0][i].gender +": $"+ obj[0][i].inventory_value +"<br>");
                }
        }
            
        else if($("#UserInput").val() == 4){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
                {
                $("#getval").append(obj[0][i].type_description +": $"+ obj[0][i].inventory_value +"<br>");
                }
        }    
        
        else if($("#UserInput").val() == 5){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
                {
                $("#getval").append(obj[0][i].color_description +": $"+ obj[0][i].inventory_value +"<br>");
                }
        }    
        
        else if($("#UserInput").val() == 6){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
                {
                $("#getval").append("Average Price: $"+ obj[0][i].average_price +"<br>");
                }
        }
        else if($("#UserInput").val() == 7){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
                {
                $("#getval").append("Model: " +obj[0][i].inventory_model +", Quantity on Hand:"+ obj[0][i].total_qty_on_hand +"<br>");
                }
        }  
        else if($("#UserInput").val() == 8){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
                {
                $("#getval").append("Model: " +obj[0][i].inventory_model +
                        " Size: "+ obj[0][i].size +" Color code: " + obj[0][i].color_color_code+" Gender: "+
                        obj[0][i].gender+" Quantity on Hand: "+ obj[0][i].quantity_available+"<br>");            
                }
        }      
        else if($("#UserInput").val() == 9){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
               {
               $("#getval").append("Model: "+obj[0][i].inventory_model +", Quantity Available: "+ obj[0][i].quantity_available +"<br>");
                
               }
         }
        else if($("#UserInput").val() == 10){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
               {
               $("#getval").append("Size: "+obj[0][i].size +", Quantity Available: "+ obj[0][i].quantity_available +"<br>");
               }
         }    
        else if($("#UserInput").val() == 11){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
               {
               $("#getval").append("Color code: "+obj[0][i].color_color_code +", Quantity Available:"+ obj[0][i].quantity_available +"<br>");
               }
         }     
        else if($("#UserInput").val() == 12){
               for(var i = 0; i < lengthOfElementsDisplayed; i++)
               {
               $("#getval").append("Gender: "+obj[0][i].gender +", Quantity Available: "+ obj[0][i].quantity_available +"<br>");
               }
         }else{
            $("#getval").append("");
         }
     
            
        }// end of renderVal


});



