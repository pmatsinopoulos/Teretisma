$(document).ready(function(){
  $("#check_for_posts").bind("ajax:complete", function(et, e){
    $("#more_posts_notification").html(e.responseText); // insert content
  });
});


