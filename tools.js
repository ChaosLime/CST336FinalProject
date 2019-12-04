const mysql = require('mysql');

module.exports = { 

     /**
      * creates database connection
      * @returns db connection
      */
    createConnection: function(){
         var conn = mysql.createConnection({
        host: 'cst336db.space',
        user: 'cst336_dbUser030',
    password: 'qq0mon',
    database: 'cst336_db030'
    });
    return conn;

    },
    

        
        
};