
 $(document).ready(function() {
  player_hits();
  player_stays();
  dealer_hits();
  get_name();
  get_bet();
});

function player_hits() {
  $(document).on("click", "form#player_hit input", function(){
    $.ajax({
      type: "POST",
      url: "/game/player/hit"
    }).done(function(msg) {
      $("#game").replaceWith(msg)
    });

    return false;
  });
}

function player_stays() {
  $(document).on("click", "form#player_stay input", function(){
    $.ajax({
      type: "POST",
      url: "/game/player/stay"
    }).done(function(msg) {
      $("#game").replaceWith(msg)
    });

    return false;
  });
}


function dealer_hits() {
  $(document).on("click", "form#dealer_hit input", function(){
    $.ajax({
      type: "POST",
      url: "/game/dealer/hit"
    }).done(function(msg) {
      $("#game").replaceWith(msg)
    });
      return false;
  });

}

function get_name() {
$("form#name").submit(function(e){
    if($('#text_field').val() ==  "") {
      e.preventDefault();
      alert("Please enter your name.");
    }
  });
};

function get_bet() {
$("form#player_bet").submit(function(e){
    if($('#bet_amount').val() ==  "") {
      e.preventDefault();
      alert("Please make a bet.");
    }
  });
};
