const faker = require("faker");
const express = require("express");
const app = express();
app.set('view engine', 'ejs');
app.set("views", "./views/");
app.use(express.static("public"));


app.engine('html', require('ejs').renderFile);

const tools = require("./tools.js");




//root route
app.get("/", async function(req, res) {
    res.render("index.html");
}); // root route



// other routes
app.get("/login", function(req, res) {
    res.render("login.html");
});

app.get("/valuations", function(req, res) {
    res.render("valuations.html");
});

app.get("/cart.html", function(req, res) {
    var conn = tools.createConnection();
    var sql = "SELECT cart.username, cart.sequence, cart.quantity_in_cart, inventory.model, " +
        "inventory.price, inventory_quantities.color_color_code AS color, inventory_quantities.gender, " +
        "inventory_quantities.size, inventory_quantities.quantity_on_hand, inventory_quantities.image_path, inventory.model_description, " +
        "CONCAT(inventory.model, inventory_quantities.color_color_code, inventory_quantities.gender, " +
        "inventory_quantities.size) AS sku FROM cart  INNER JOIN inventory ON " +
        "cart.inventory_quantities_inventory_model = inventory.model INNER JOIN inventory_quantities " +
        "ON cart.inventory_quantities_inventory_model = inventory_quantities.inventory_model " +
        "AND cart.inventory_quantities_size = inventory_quantities.size " +
        "AND cart.inventory_quantities_color_color_code = inventory_quantities.color_color_code " +
        "AND cart.inventory_quantities_gender = inventory_quantities.gender " +
        "WHERE cart.username = ? ORDER BY sequence";
    //var sqlParams = req.query.username;

    var sqlParams = "generic";

    conn.connect(function(err) {
        if (err) throw err;
        conn.query(sql, sqlParams, function(err, result) {
            if (err) throw err;
            res.render("cart.html", { "itemsInCart": result });
        });
    });
});


app.get("/signedUp.html", function(req, res) {
    res.render("signedUp.html");
});

//getting fake name and zip code data from faker API
app.get("/ordered", function(req, res) {
    res.render("ordered.html", { "name": faker.name.findName(), "address": faker.address.zipCode() });
});

//queries to DB

//gets all from inventory
app.get("/db/displayInventory", async function(req, res) {
    var conn = tools.createConnection();
    var sql;
    var sqlParams;

    if (req.query.action == "loadProduct") {
        sql = "CALL getFilteredProductList (?,?,?,?);";
        sqlParams = [req.query.color, req.query.gender, req.query.styles, req.query.size];
        console.log("Search Params:" + sqlParams);
    }
    sql = "CALL getFilteredProductList (?,?,?,?);";
    sqlParams = [req.query.color, req.query.gender, req.query.styles, req.query.size];

    conn.connect(function(err) {

        if (err) throw err;

        conn.query(sql, sqlParams, function(err, result) {
            if (err) throw err;
            conn.on('error', function(err) {
                console.log(err.code); // 'ER_BAD_DB_ERROR'
            });
            if (result == " ") {
                alert("empty result.");
                conn.end();
            }

            /*This block below is intended to clean up and modify the results from the database
            as a string and parse is accordingly. The counter limits the amount of results to be displayed,
            if omited in the split method, will return all results of that query.
            For multiple result, it is simply seperated by a ",". Could not quite parse nicely with
            JSON from the database therefore was stringified and adjusted.
            */
            var stringifiedResult = JSON.stringify(result);
            var splitResult = stringifiedResult.split(",RowDataPacket ");
            var replacedString = splitResult.toString().replace(/[^a-zA-Z0-9[]_:.{},\/"]/g, ' ').replace(/  +/g, ' ');
            //sets up data to be parsed and displayed on screen
            //console.log(replacedString);
            res.send(replacedString); //This is the correct method to use to pass information back
            conn.end();
        });

    });

}); //display Inventory


//gets all from inventory
app.get("/db/getValuation", async function(req, res) {
    var conn = tools.createConnection();
    var sql;
    var sqlParams;

    sql = "CALL getInventoryValuation(?);";
    sqlParams = [req.query.userInput];

    conn.connect(function(err) {

        if (err) throw err;

        conn.query(sql, sqlParams, function(err, result) {
            if (err) throw err;
            conn.on('error', function(err) {
                console.log(err.code); // 'ER_BAD_DB_ERROR'
            });
            if (result == " ") {
                alert("empty result.");
                conn.end();
            }

            /*This block below is intended to clean up and modify the results from the database
            as a string and parse is accordingly. The counter limits the amount of results to be displayed,
            if omited in the split method, will return all results of that query.
            For multiple result, it is simply seperated by a ",". Could not quite parse nicely with
            JSON from the database therefore was stringified and adjusted.
            */
            var stringifiedResult = JSON.stringify(result);
            var splitResult = stringifiedResult.split(",RowDataPacket ");
            var replacedString = splitResult.toString().replace(/[^a-zA-Z0-9[]_:.{},\/"]/g, ' ').replace(/  +/g, ' ');
            //sets up data to be parsed and displayed on screen
            //console.log(replacedString);
            res.send(replacedString); //This is the correct method to use to pass information back
            conn.end();
        });

    });

}); //display Inventory





//gets all from inventory
app.get("/db/insertIntoCart", async function(req, res) {
    var conn = tools.createConnection();
    var sql;
    var sqlParams;
    sql = "CALL transaction_add_cart_item (?,?,?,?,?,?);";
    sqlParams = [req.query.username, req.query.inventory_quantities_inventory_model,
        req.query.inventory_quantities_size, req.query.inventory_quantities_color_color_code,
        req.query.inventory_quantities_gender, req.query.quantity_in_cart
    ];

    conn.connect(function(err) {

        if (err) throw err;

        conn.query(sql, sqlParams, function(err, result) {
            if (err) throw err;
            conn.on('error', function(err) {
                console.log(err.code); // 'ER_BAD_DB_ERROR'
            });
            res.send(result);
            conn.end();
        });

    });

}); //Insert Inventory

app.get("/db/displayCart", async function(req, res) {
    var conn = tools.createConnection();
    var sql;
    var sqlParams;
    sql = "CALL getCartItems(?);";
    sqlParams = [req.query.username];

    conn.connect(function(err) {

        if (err) throw err;

        conn.query(sql, sqlParams, function(err, result) {
            if (err) throw err;
            conn.on('error', function(err) {
                console.log(err.code); // 'ER_BAD_DB_ERROR'
            });
            var stringifiedResult = JSON.stringify(result);
            var splitResult = stringifiedResult.split(",RowDataPacket ");
            var replacedString = splitResult.toString().replace(/[^a-zA-Z0-9[]_:.{},\/"]/g, ' ').replace(/  +/g, ' ');
            //sets up data to be parsed and displayed on screen
            res.send(replacedString); //This is the correct method to use to pass information back
            conn.end();
        });
    });

}); //display Inventory

//get user cart contents
app.get("/api/getInventoryForCartItems", function(req, res) {

    var conn = tools.createConnection();
    var sql = "SELECT cart.username, cart.sequence, cart.quantity_in_cart, " +
        "inventory_quantities.quantity_on_hand FROM cart " +
        "INNER JOIN inventory " +
        "ON cart.inventory_quantities_inventory_model = inventory.model " +
        "INNER JOIN inventory_quantities " +
        "ON cart.inventory_quantities_inventory_model = inventory_quantities.inventory_model " +
        "AND cart.inventory_quantities_size = inventory_quantities.size " +
        "AND cart.inventory_quantities_color_color_code = inventory_quantities.color_color_code " +
        "AND cart.inventory_quantities_gender = inventory_quantities.gender " +
        "WHERE cart.username = ? ORDER BY sequence";
    var sqlParams = req.query.username;

    conn.connect(function(err) {
        if (err) throw err;
        conn.query(sql, sqlParams, function(err, result) {
            if (err) throw err;
            res.send(result);
        });
    });
});

app.get("/api/updateCartQuantity", function(req, res) {
    var conn = tools.createConnection();
    var sql = "UPDATE cart " +
        "SET quantity_in_cart = ? " +
        "WHERE username = ? AND sequence = ?";
    //var sqlParams = req.query.username;
    var sqlParams = [req.query.newQuantity, req.query.username, req.query.sequence];

    conn.connect(function(err) {
        if (err) throw err;
        conn.query(sql, sqlParams, function(err, result) {
            if (err) throw err;
        });
    });
});

app.get("/api/deleteFromCart", function(req, res) {

    var conn = tools.createConnection();
    var sql = "DELETE FROM cart " +
        "WHERE username = ? AND sequence = ?";
    //var sqlParams = req.query.username;
    var sqlParams = [req.query.username, req.query.sequence];

    conn.connect(function(err) {
        if (err) throw err;
        conn.query(sql, sqlParams, function(err, result) {
            if (err) throw err;
        });
    });
});

app.get("/api/createOrder", function(req, res) {

    var conn = tools.createConnection();
    var sql = 'CALL transaction_checkout(?)';
    var sqlParams = req.query.username;

    conn.connect(function(err) {
        if (err) throw err;
        conn.query(sql, sqlParams, function(err, result) {
            if (err) throw err;
        });
    });
});

app.listen(process.env.PORT, process.env.IP, function() {
    console.log("Running Express Server...");
});
