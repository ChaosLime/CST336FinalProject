const express = require("express");
const app = express();
app.engine('html', require('ejs').renderFile);
app.use(express.static("public"));

//routes
app.get("/", function(req,res){
    res.render("index.html");
});

app.get("/index5.html", function(req,res){
    res.render("index5.html");
});

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


//server listener
//for local testing
/*
app.listen("8080","127.0.0.1", function(){
    console.log("Running Express Server...");
});
*/

app.listen(process.env.PORT, process.env.IP, function(){
    console.log("Running Express Server...");
});