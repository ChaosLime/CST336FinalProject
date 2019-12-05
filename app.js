const express = require("express");
const app = express();
app.set('view engine','ejs');
app.set("views", "./views/");
app.use(express.static("public"));


app.engine('html', require('ejs').renderFile);

const tools = require("./tools.js");




//root route
app.get("/", async function(req,res){
    res.render("index.html");
});// root route



// other routes
app.get("/login.html", function(req,res){
    res.render("login.html");
});

app.get("/cart.html", function(req,res){
    res.render("cart.html");
});

app.get("/forgotPasswd.html", function(req,res){
    res.render("forgotPasswd.html");
});

app.get("/signedUp.html", function(req,res){
    res.render("signedUp.html");
});

app.get("/ordered.html", function(req,res){
    res.render("ordered.html");
});

//queries to DB

//gets all from inventory
app.get("/db/displayInventory", async function(req,res){
    var conn = tools.createConnection();
    var sql;
    var sqlParams;
    
    if(req.query.action == "loadProduct"){
         sql ="CALL getFilteredProductList (?,?,?);";
         sqlParams = [req.query.color, req.query.gender, req.query.styles];
         console.log("Search Params:"+sqlParams);
    }
   
 
    conn.connect( function(err){
        
      if (err) throw err;
      
        conn.query(sql,sqlParams, function(err, result){
            if (err) throw err;
            /*This block below is intended to clean up and modify the results from the database
            as a string and parse is accordingly. The counter limits the amount of results to be displayed,
            if omited in the split method, will return all results of that query.
            For multiple result, it is simply seperated by a ",". Could not quite parese JSON using a database
            there fore parsing a string is another solution.
            */
                var amountOfResults = 1;
                
                var myDataString = JSON.stringify(result);
                myDataString = myDataString.split(/-/, amountOfResults);
                console.log(amountOfResults + " Result(s) Displayed");
                var cleanStr = myDataString.toString().replace(/[^a-zA-Z0-9_:.,]/g,' ').replace(/  +/g, ' ');
                console.log(cleanStr);
                return cleanStr;
                
           
        });
        console.log('Connected!');
    });

});//display Inventory



app.listen(process.env.PORT, process.env.IP, function(){
    console.log("Running Express Server...");
});