$(function () {
    
    $("input.required[type=text],textarea.required,input.required[type=password]").blur(function () {
        if (($(this).val().trim() == "" || $(this).val() == null)) {
            $(this).closest('.form-group').addClass('has-error');
        }
        else {
            $(this).closest('.form-group').removeClass('has-error');
        }
    });

    $(".password,.confirmPassword").blur(function () {
        if ($(".password").val() != $(".confirmPassword").val() || $(".password").val() == '') {
            $(".password,.confirmPassword").closest('.form-group').addClass('has-error');
        }
        else {
            $(".password,.confirmPassword").closest('.form-group').removeClass('has-error');
        }
    });

    $("select.required").blur(function () {
        if (($(this).prop('selectedIndex') == 0)) {
            $(this).closest('.form-group').addClass('has-error');
        }
        else {
            $(this).closest('.form-group').removeClass('has-error');
        }
    });

    $(".emailAddress").blur(function () {
        var expression = /^\w+([-+.'][^\s]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
        if (!expression.test($(this).val())) {
            $(this).closest('.form-group').addClass('has-error');
        }
        else {
            $(this).closest('.form-group').removeClass('has-error');
        }
    });
});


var InputValidation = {

    IsFormValid: function (context) {
        //// For required input box controls
        $("input.required[type=text],textarea.required,input.required[type=password]", $(context)).each(function () {
            if (($(this).val().trim() == "" || $(this).val() == null)) {
                $(this).closest('.form-group').addClass('has-error');
            }
            else {
                $(this).closest('.form-group').removeClass('has-error');
            }
        });

        $("select.required", $(context)).each(function () {
            if (($(this).prop('selectedIndex') == 0)) {
                $(this).closest('.form-group').addClass('has-error');
            }
            else {
                $(this).closest('.form-group').removeClass('has-error');
            }
        });

        if ($(".password", $(context)).length == 1) {
            if ($(".password", $(context)).val() != $(".confirmPassword", $(context)).val() || $(".password", $(context)).val() == '') {
                $(".password,.confirmPassword", $(context)).closest('.form-group').addClass('has-error');
            }
            else {
                $(".password,.confirmPassword", $(context)).closest('.form-group').removeClass('has-error');
            }
        }

        $(".emailAddress", $(context)).each(function () {
            var expression = /^\w+([-+.'][^\s]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
            if (!expression.test($(this).val())) {
                $(this).closest('.form-group').addClass('has-error');
            }
            else {
                $(this).closest('.form-group').removeClass('has-error');
            }
        });

        if ($('.has-error', $(context)).length > 0) {
            return false;
        }
        else {
            return true;
        }
    }
}