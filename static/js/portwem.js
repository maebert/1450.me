var header_height = 0;
var inital_motion = null;
var ma = null;
function moving_average(period) {
    var nums = [];
    return function(num) {
        nums.push(num);
        if (nums.length > period)
            nums.splice(0,1);  // remove the first element of the array
        var sum = 0;
        for (var i in nums)
            sum += nums[i];
        var n = period;
        if (nums.length < period)
            n = nums.length;
        return(sum/n);
    }
}

function clamp (v)
    {
    return Math.max(Math.min(v, 1.0), 0.0);
    }

function goggles (percent)
    {
    var $left = document.getElementById("goggleLeft");
    var $right = document.getElementById("goggleRight");
    $left.style.marginTop = -27*percent+"px";
    $left.style.marginLeft = 4*percent+"px";
    $left.style.webkitTransform = "scaleY("+(1-0.25*percent)+") rotate("+(-20*percent)+"deg)";
    $left.style.mozTransform = "scaleY("+(1-0.25*percent)+") rotate("+(-20*percent)+"deg)";
    $left.style.oTransform = "scaleY("+(1-0.25*percent)+") rotate("+(-20*percent)+"deg)";
    $left.style.transform = "scaleY("+(1-0.25*percent)+") rotate("+(-20*percent)+"deg)";
    $right.style.marginTop = -27*percent+"px";
    $right.style.marginLeft = -4*percent+"px";
    $right.style.webkitTransform = "scaleY("+(1-0.25*percent)+") rotate("+(20*percent)+"deg)";
    $right.style.mozTransform = "scaleY("+(1-0.25*percent)+") rotate("+(20*percent)+"deg)";
    $right.style.oTransform = "scaleY("+(1-0.25*percent)+") rotate("+(20*percent)+"deg)";
    $right.style.transform = "scaleY("+(1-0.25*percent)+") rotate("+(20*percent)+"deg)";
    }

function avatar (percent)
    {
    var t = (percent + 1) * (header_height / 2 - 140);
    $(".avatar").css("top", t + "px");
    }
function name (percent)
    {
    var t = (percent + 1) * (header_height / 2 - 100);
    $("#name").css({
        "top": t + "px",
        "opacity": clamp(1 - (percent * 2))
        });
    }

function navbar (percent)
    {
    if (percent >= 1) { $("body").addClass("fixnav"); }
    else { $("body").removeClass("fixnav"); }
    if (percent > 0) { $("body").addClass("showbrand"); }
    else { $("body").removeClass("showbrand"); }
    }


function scroll ()
    {
    var p = $(window).scrollTop() /header_height;
    goggles(clamp(p*2));
    avatar(p*1.8);
    name(p*1.8);
    navbar(p);
    }


$(function()
    {
    header_height = window.innerHeight - $("nav").height();
    $("header").css("height", header_height + "px");

    if (window.DeviceOrientationEvent) {
        ma = moving_average(10);
        window.ondevicemotion = function(event) {

            var acc = event.accelerationIncludingGravity.z;
            if (inital_motion === null) {
                inital_motion = acc;
            } else {
                goggles(clamp(ma(inital_motion - acc) / 3.0));
            }
        }
    }

    if (!window.matchMedia("(max-width: 768px)").matches)
        {
        $(".avatar").css("top", header_height / 2 - 140 + "px");
        scroll();
        $(window).resize(scroll).scroll(scroll);
        }
    else
        {
        $(".avatar").css("top", header_height / 2 - 90 + "px");
        $("#name").css("top", header_height / 2 - 70 + "px");

        }
    });
