var express = require('express')
var app = express()

// SHOW LIST OF USERS
app.get('/', function(req, res, next) {
	req.getConnection(function(error, conn) {
		conn.query('SELECT * FROM inventory ORDER BY model DESC',function(err, rows, fields) {
			//if(err) throw err
			if (err) {
				req.flash('error', err)
				res.render('user/list', {
					title: 'Item List', 
					data: ''
				})
			} else {
				// render to views/user/list.ejs template file
				res.render('user/list', {
					title: 'Item List', 
					data: rows
				})
			}
		})
	})
})

// SHOW Complete inventory valuation Report
app.get('/report1', function(req, res, next) {
	req.getConnection(function(error, conn) {
		conn.query('CALL getInventoryValuation(1)',function(err, rows, fields) {
			//if(err) throw err
			if (err) {
				req.flash('error', err)
				res.render('user/report1', {
					title: 'Complete Inventory Valuation', 
					data: ''
				})
			} else {
				// render to views/user/list.ejs template file
				res.render('user/report1', {
					title: 'Complete Inventory Valuation', 
					data: rows
				})
			}
		})
	})
})

// SHOW Complete inventory valuation Report
app.get('/report2', function(req, res, next) {
	req.getConnection(function(error, conn) {
		conn.query('CALL getInventoryValuation(12)',function(err, rows, fields) {
			//if(err) throw err
			if (err) {
				req.flash('error', err)
				res.render('user/report2', {
					title: 'Total Qty available by Gender', 
					data: ''
				})
			} else {
				// render to views/user/list.ejs template file
				res.render('user/report2', {
					title: 'Total Qty available by Gender', 
					data: rows
				})
			}
		})
	})
})

// SHOW ADD USER FORM
app.get('/add', function(req, res, next){	
	// render to views/user/add.ejs
	res.render('user/add', {
		title: 'Add New Inventory',
		model: '',
		model_description: '',
		model_detailed_description: '',
		price: ''
	
	})
})

// ADD NEW USER POST ACTION
app.post('/add', function(req, res, next){	
	req.assert('model', 'Model Name is required').notEmpty()           //Validate name
	req.assert('price', 'Price is required').notEmpty()             //Validate age

    var errors = req.validationErrors()
    
    if( !errors ) {   //No errors were found.  Passed Validation!
		
		/********************************************
		 * Express-validator module
		 
		req.body.comment = 'a <span>comment</span>';
		req.body.username = '   a user    ';

		req.sanitize('comment').escape(); // returns 'a &lt;span&gt;comment&lt;/span&gt;'
		req.sanitize('username').trim(); // returns 'a user'
		********************************************/
		var item = {
			model: req.sanitize('model').escape().trim(),
			model_description: req.sanitize('model_description').escape().trim(),
			model_detailed_description: req.sanitize('model_detailed_description').escape().trim(),
			price: req.sanitize('price').escape().trim()
			
			
		}
		
		req.getConnection(function(error, conn) {
			conn.query('INSERT INTO inventory SET ?', item, function(err, result) {
				//if(err) throw err
				if (err) {
					req.flash('error', err)
					
					// render to views/user/add.ejs
					res.render('user/add', {
						title: 'Add New Item',
						model: item.model,
						model_description: item.model.model_description,
						model_detailed_description: item.model_detailed_description,
						price: item.price
						
					})
				} else {				
					req.flash('success', 'Data added successfully!')
					
					// render to views/user/add.ejs
					res.render('user/add', {
						title: 'Add New Item',
						model: '',
						model_description: '',
						model_detailed_description: '',
						price: ''
						
					})
				}
			})
		})
	}
	else {   //Display errors to user
		var error_msg = ''
		errors.forEach(function(error) {
			error_msg += error.msg + '<br>'
		})				
		req.flash('error', error_msg)		
		
		/**
		 * Using req.body.name 
		 * because req.param('name') is deprecated
		 */ 
        res.render('user/add', { 
            title: 'Add New Item',
            model: req.body.model,
            model_description: req.body.model_description,
            model_detailed_description: req.body.model_detailed_description,
            price: req.body.price,
            
        })
    }
})



// SHOW EDIT USER FORM
app.get('/edit/(:id)', function(req, res, next){
	req.getConnection(function(error, conn) {
		conn.query('SELECT * FROM inventory WHERE id = ?', [req.params.id], function(err, rows, fields) {
			if(err) throw err
			
			// if user not found
			if (rows.length <= 0) {
				req.flash('error', 'Item not found with model id = ' + req.params.id)
				res.redirect('/users')
			}
			else { // if user found
				console.log('Item found with model id = ' + req.params.id);
				// render to views/user/edit.ejs template file
				res.render('user/edit', {
					title: 'Edit Item', 
					//data: rows[0],
					id: rows[0].id,
					model: rows[0].model,
					model_description: rows[0].model_description,
					model_detailed_description: rows[0].model_detailed_description,
					price: rows[0].price					
				})
			}			
		})
	})
})

// EDIT USER POST ACTION
app.put('/edit/(:id)', function(req, res, next) {
	req.assert('model', 'Model Name is required').notEmpty()           //Validate name
	req.assert('price', 'Price is required').notEmpty()             //Validate age

    var errors = req.validationErrors()
    
    if( !errors ) {   //No errors were found.  Passed Validation!
		
		/********************************************
		 * Express-validator module
		 
		req.body.comment = 'a <span>comment</span>';
		req.body.username = '   a user    ';

		req.sanitize('comment').escape(); // returns 'a &lt;span&gt;comment&lt;/span&gt;'
		req.sanitize('username').trim(); // returns 'a user'
		********************************************/
		var item = {
			model: req.sanitize('model').escape().trim(),
			model_description: req.sanitize('model_description').escape().trim(),
			model_detailed_description: req.sanitize('model_detailed_description').escape().trim(),
			price: req.sanitize('price').escape().trim()
		}
		
		req.getConnection(function(error, conn) {
			conn.query('UPDATE inventory SET ? WHERE id = ' + req.params.id, item, function(err, result) {
				//if(err) throw err
				if (err) {
					req.flash('error', err)
					
					
					// render to views/user/add.ejs
					res.render('user/edit', {
						title: 'Edit User',
						id: req.params.id,
						model: req.body.model,
						model_description: req.body.model_description,
            			model_detailed_description: req.body.model_detailed_description,
            			price: req.body.price
					})
				} else {
					req.flash('success', 'Data updated successfully!')
					
					// render to views/user/add.ejs
					res.render('user/edit', {
						title: 'Edit User',
						id: req.params.id,
						model: req.body.model,
						model_description: req.body.model_description,
            			model_detailed_description: req.body.model_detailed_description,
            			price: req.body.price
					})
				}
			})
		})
	}
	else {   //Display errors to user
		var error_msg = ''
		errors.forEach(function(error) {
			error_msg += error.msg + '<br>'
		})
		req.flash('error', error_msg)
		
		/**
		 * Using req.body.name 
		 * because req.param('name') is deprecated
		 */ 
        res.render('user/edit', { 
            title: 'Edit User',
            id: req.params.id,
			model: req.params.model, 
			model_description: req.body.model_description,
            model_detailed_description: req.body.model_detailed_description,
            price: req.body.price
        })
    }
})

// DELETE USER
app.delete('/delete/(:id)', function(req, res, next) {
	var item = { id: req.params.id }
	
	req.getConnection(function(error, conn) {
		conn.query('DELETE FROM inventory WHERE id = ' + req.params.id, item, function(err, result) {
			//if(err) throw err
			if (err) {
				req.flash('error', err)
				// redirect to users list page
				res.redirect('/users')
			} else {
				req.flash('success', 'User deleted successfully! id = ' + req.params.id)
				// redirect to users list page
				res.redirect('/users')
			}
		})
	})
})

module.exports = app
