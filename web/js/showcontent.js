$(document).ready(function(){
    $("#skill_container #skill_property").show();
    $("#nav a").click(function(){
        var id =  $(this).attr('id');
        id = id.split('_');
        $("#skill_container div").hide();
        $("#skill_container #skill_"+id[1]).show();
    });


});