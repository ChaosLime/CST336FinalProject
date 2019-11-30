const express = require("express");
const app = express();
app.set('view engine','ejs');
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
    var sql = "SELECT * FROM inventory;";

    conn.connect( function(err){
      if (err) throw err;
        conn.query(sql, function(err, result){
            if (err) throw err;
            console.log(result);
        });
        console.log('Connected!');
    });


});//display Inventory





app.listen(process.env.PORT, process.env.IP, function(){
    console.log("Running Express Server...");
});