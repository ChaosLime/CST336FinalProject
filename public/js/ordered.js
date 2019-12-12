$(document).ready(function() {

   updateDeliveryDescription();

   function updateDeliveryDescription() {

      $("#deliveryDescription").html("");

      let zipCode = $("#zipToShip").text().substring(0, 5);

      //getting city and state from zip code using API
      $.ajax({
         method: "GET",
         url: "https://itcdland.csumb.edu/~milara/ajax/cityInfoByZip.php",
         dataType: "json",
         data: { "zip": zipCode },
         success: function(result, status) {
            if (result) {
               $("#zipToShip").text(result.city + ", " + result.state);
               getInTransitTime(zipCode);
            }
         }
      }); //ajax

   }

   function getInTransitTime(zipCode) {
      let today = new Date();

      $.ajax({
         method: "POST",
         url: "https://onlinetools.ups.com/rest/TimeInTransit",
         dataType: "json",
         data: {
            "Security": {
               "UsernameToken": {
                  "Username": "mikiereed",
                  "Password": "CST336Password"
               },
               "UPSServiceAccessToken": {
                  "AccessLicenseNumber": "9D7286BC379499F2"
               }
            },
            "TimeInTransitRequest": {
               "Request": {
                  "RequestOption": "TNT",
                  "TransactionReference": {
                     "CustomerContext": "",
                     "TransactionIdentifier": ""
                  }
               },
               "ShipFrom": {
                  "Address": {
                     "StateProvinceCode": "CA",
                     "CountryCode": "1",
                     "PostalCode": "91010"
                  }
               },
               "ShipTo": {
                  "Address": {
                     "CountryCode": "1",
                     "PostalCode": zipCode
                  }
               },
               "Pickup": {
                  "Date": today
               },
            }
         },
         success: function(result, status) {
            alert(result);
         }
      });
   }
});
