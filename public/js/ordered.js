$(document).ready(function() {

   //updateDeliveryDescription();

   function updateDeliveryDescription() {

      $("#deliveryDescription").html("");

      //getting city and state from zip code using API
      //alert($("#zip").val());
      $("#city").html("Zip Code Not Found");
      $("#latitude").html("");
      $("#longitude").html("");
      $.ajax({
         method: "GET",
         url: "https://cst336.herokuapp.com/projects/api/cityInfoAPI.php",
         dataType: "json",
         data: { "zip": $("#zip").val() },
         success: function(result, status) {
            //alert(result.city);
            $("#city").html(result.city);
            $("#city").css("color", "black");
            $("#latitude").html(result.latitude);
            $("#longitude").html(result.longitude);
         }
      }); //ajax
   }); //zip
}
});
