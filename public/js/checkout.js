$(document).ready(function() {

  /* Set values + misc */
  var tax_rate = 0.08;
  var fadeTime = 300;

  updateSumItems();
  //getCartSum();

  /* Assign actions */
  $('.quantity input').change(function() {
    updateQuantity(this);
  });

  $('.remove button').click(function() {
    removeItem(this);
  });

  $(".checkout-cta").on("click", function() {
    // TODO: run Mitchell's SQL transaction to clear cart
    window.open('ordered.html', '_self', false);
  });

  /* Recalculate cart */
  function recalculateCart(onlyTotal) {
    var subtotal = 0;

    /* Sum up row totals */
    $('.cart-product').each(function() {
      subtotal += parseFloat($(this).children('.subtotal').text());
    });

    /* Calculate totals */
    var total = subtotal;

    /*If switch for update only total, update only total display*/
    if (onlyTotal) {
      /* Update total display */
      $('.total-value').fadeOut(fadeTime, function() {
        $('#cart-total').html(total.toFixed(2));

        $('.total-value').fadeIn(fadeTime);
      });
    }
    else {
      /* Update summary display. */
      $('.final-value').fadeOut(fadeTime, function() {
        $('#cart-subtotal').html(subtotal.toFixed(2));
        var tax = parseFloat((total * tax_rate));
        var totalVal = parseFloat(total);
        $('#taxes').html(tax.toFixed(2));
        // total cost = subtotals + tax
        $('#cart-total').html((parseFloat(totalVal) + parseFloat(tax)).toFixed(2));
        if (total == 0) {
          $('.checkout-cta').fadeOut(fadeTime);
        }
        else {
          $('.checkout-cta').fadeIn(fadeTime);
        }
        $('.final-value').fadeIn(fadeTime);
      });
    }
  }

  /* Update quantity */
  function updateQuantity(quantityInput) {
    /* Update db cart */
    let sequenceId = $(quantityInput).parent().parent().attr('id');
    updateCartQuantity(sequenceId, $(quantityInput).val());

    /* Calculate line price */
    var productRow = $(quantityInput).parent().parent();
    var price = parseFloat(productRow.children('.price').text());
    var quantity = $(quantityInput).val();
    var linePrice = price * quantity;

    /* Update line price display and recalc cart totals */
    productRow.children('.subtotal').each(function() {
      $(this).fadeOut(fadeTime, function() {
        $(this).text(linePrice.toFixed(2));
        recalculateCart();
        $(this).fadeIn(fadeTime);
      });
    });

    productRow.find('.item-quantity').text(quantity);
    updateSumItems();
  }

  function updateSumItems() {
    var sumItems = 0;
    $('.quantity-field').each(function() {
      sumItems += parseInt($(this).val());
    });

    $('#total-items').text(sumItems);
  }

  /* Remove item from cart */
  function removeItem(removeButton) {
    /* Remove row from DOM and recalc cart total */
    var productRow = $(removeButton).parent().parent();
    let sequenceId = productRow.attr('id');
    deleteItemFromCart(sequenceId);
    productRow.slideUp(fadeTime, function() {
      productRow.remove();
      recalculateCart();
      updateSumItems();
    });
  }

  function getCurrentInventory() {
    $.ajax({
      method: "get",
      url: "/api/getInventoryForCartItems",
      data: {
        //"username": $("#username").val()
        "username": "generic"
      },
      success: function(result, status) {
        checkAndUpdateQuantity(result);
      }
    });
  }

  function deleteItemFromCart(sequence) {
    $.ajax({
      method: "get",
      url: "/api/deleteFromCart",
      data: {
        //"username": $("#username").val()
        "username": "generic",
        "sequence": sequence
      }
    });
  }

  function updateCartQuantity(sequence, newQuantity) {
    $.ajax({
      method: "get",
      url: "/api/updateCartQuantity",
      data: {
        //"username": $("#username").val()
        "username": "generic",
        "sequence": sequence,
        "newQuantity": newQuantity
      }
    });
  }

});
