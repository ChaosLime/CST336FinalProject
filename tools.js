const mysql = require('mysql');

module.exports = { 

     /**
      * creates database connection
      * @returns db connection
      */
    createConnection: function(){
         var conn = mysql.createConnection({
        host: 'us-cdbr-iron-east-05.cleardb.net',
        user: 'bc0ca7ea703d0d',
    password: 'c8af3bcc',
    database: 'heroku_35b42c01aef0b09'
    });
    return conn;

    },
    

        
};