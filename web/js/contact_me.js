var ContactForm = function(){

    $('#contactForm').submit(function(evt) {

        evt.preventDefault();

        var formInput = $(this).serialize();

        var name = $('input[name="name"]').val();
        var companyname = $('input[name="companyname"]').val();
        var email = $('input[name="email"]').val();
        var number = $('input[name="number"]').val();
        var message = $('input[name="message"]').val();

        if (name == '' || companyname == '' || email == '' || number == '' || message == '') {
            $(".form-error-messages").text("Please Fill Required Fields *").fadeIn();
            return false;
        }
        else if (!$.isNumeric(number)){
            $(".form-error-messages").text("Please enter a valid phone number. (e.g +12345, 12345) excluding spaces").fadeIn();
            return false;
        }
        else if ( !isEmail(email)  ) {
            $(".form-error-messages").text("Please enter a valid email address").fadeIn();
            return false;
        }
        else {
            $.post($(this).attr('action'),formInput, function(data){
                $(".form-error-messages").text("Please Fill Required Fields *").fadeOut();
             if (data.success) {
                 $('#success').html("<div class='alert alert-success'>");
                 $('#success > .alert-success').html("<button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;").append("</button>");
                 $('#success > .alert-success').append("<strong>Your message has been sent. </strong>");
                 $('#success > .alert-success').append('</div>');
                 $('#contactForm').trigger("reset");
             } else {
                 $('#success').html("<div class='alert alert-danger'>");
                 $('#success > .alert-danger').html("<button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;").append("</button>");
                 $('#success > .alert-danger').append("<strong>Sorry, it seems that my mail server is not responding. Please try again later!");
                 $('#success > .alert-danger').append('</div>');
                 $('#contactForm').trigger("reset");
             }

             return false;

        });

        }
        return false;
    });

}

function isEmail(email) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
}

$(document).ready(function() {
    ContactForm();
});
