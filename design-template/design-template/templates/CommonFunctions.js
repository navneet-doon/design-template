var GlobalMessages = {
    FormOrganizationValidationFailedMessage: "Please fill required fields with valid inputs!"
};

$(document).ready(function () {
    //$(".datepicker").datepicker();
    //********* Ajax global events **********
    CommonUtility.InitiateAjaxHandler();
    if (CommonUtility.GetCookieByName("ActiveSideMenuOrder") == null)
        CommonUtility.SetActiveMenuCookie("1");

    $.each($('#side-menu a'), function () {
        if ($(this).attr('order') == CommonUtility.GetCookieByName("ActiveSideMenuOrder")) {
            $(this).addClass('active');
            if ($(this).parent().closest('ul').attr('aria-expanded') == 'false') {
                $(this).parent().closest('ul').attr('aria-expanded', 'true');
                $(this).parent().closest('ul').addClass('in');
            }
        }
    });
});

//$(document).ajaxError(function (event, jqxhr, settings, exception) {
//    if (jqxhr.status === 1) {
//        location.reload();
//    }
//});

var CommonUtility = {
    InitiateAjaxHandler: function () {
        $(document).ajaxStart(function () {
            $("#loader-Container").show();
        }).ajaxStop(function () {
            $("#loader-Container").hide();
        });
    },

    CallAjaxService: function (method, serviceUrl, data, successCallback, errorCallback) {
        $.ajax({
            type: method,
            url: serviceUrl,
            data: JSON.stringify(data),
            contentType: 'application/json',
            dataType: 'json',
            success: successCallback,
            error: errorCallback
        });
    },

    CallAjaxServiceFileUpload: function (method, serviceUrl, data, successCallback, errorCallback) {
        $.ajax({
            type: method,
            url: serviceUrl,
            data: data,
            contentType: false,
            dataType: 'json',
            processData: false,
            success: successCallback,
            error: errorCallback
        });
    },

    ShowStatus: function (ref, message) {       
        $(ref).html(message);
        $(ref).parent().removeClass('hidden');
        $(ref).parent().fadeIn(500);
        $(ref).parent().fadeOut(10000);       
    },

    GetCookieByName: function (name) {
        var re = new RegExp(name + "=([^;]+)");
        var value = re.exec(document.cookie);
        return (value != null) ? unescape(value[1]) : null;
    },

    SetActiveMenuCookie: function (order) {
        var mins = 30;
        var date = new Date();
        date.setTime(date.getTime() + (mins * 60 * 1000));
        document.cookie = "ActiveSideMenuOrder=" + order + ";expires=" + date.toGMTString() + ";path=/";
    },

    ClearCookieOnLogOut: function (logOutAction) {
        document.cookie = "ActiveSideMenuOrder=;expires=Thu,01 Jan 1970 00:00:00 UTC;path=/;";
        window.location.href = logOutAction;
    }
};