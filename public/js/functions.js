$(document).ready(function(){

    $("#searchBtnMain").on("click", function(){
      $.ajax({
            type: "GET",
            url: "db/displayInventory", 
          });
    });

});
    
