var header_height = 0;
function goggles (percent)
    {
    var $left = document.getElementById("goggleLeft");
    var $right = document.getElementById("goggleRight");
    $left.style.marginTop = -27*percent+"px";
    $left.style.marginLeft = 4*percent+"px";
    $left.style.webkitTransform = "scaleY("+(1-.25*percent)+") rotate("+(-20*percent)+"deg)";
    $left.style.mozTransform = "scaleY("+(1-.25*percent)+") rotate("+(-20*percent)+"deg)";
    $left.style.oTransform = "scaleY("+(1-.25*percent)+") rotate("+(-20*percent)+"deg)";
    $left.style.transform = "scaleY("+(1-.25*percent)+") rotate("+(-20*percent)+"deg)";
    $right.style.marginTop = -27*percent+"px";
    $right.style.marginLeft = -4*percent+"px";
    $right.style.webkitTransform = "scaleY("+(1-.25*percent)+") rotate("+(20*percent)+"deg)";
    $right.style.mozTransform = "scaleY("+(1-.25*percent)+") rotate("+(20*percent)+"deg)";
    $right.style.oTransform = "scaleY("+(1-.25*percent)+") rotate("+(20*percent)+"deg)";
    $right.style.transform = "scaleY("+(1-.25*percent)+") rotate("+(20*percent)+"deg)";
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
        "top": t + "px"
      , "opacity": clamp(1 - (percent * 2))
        });
    }

function navbar (percent)
    {
    if (percent >= 1)
        $("body").addClass("fixnav")
    else
        $("body").removeClass("fixnav")
    }

function scroll ()
    {
    var p = $(window).scrollTop() /header_height;
    goggles(clamp(p*2));
    avatar(p*1.8);
    name(p*1.8);
    navbar(p)
    }

function clamp (v)
    {
    return Math.max(Math.min(v, 1.0), 0.0);
    }

$(function()
    {
    // var $modal = $('#portofolio-modal');
    // $('.portofolio-tile').bind('click', function()
    //     { // create the backdrop and wait for next modal to be triggered
    //     $('body').modalmanager('loading');
    //     source = $(this).data('source')
    //     $modal.load(source, '', function()
    //         {
    //         $modal.modal(
    //             {
    //                 modalOverflow: true
    //             });
    //         });
    //     });

    header_height = window.innerHeight - $("nav").height();
    $("header").css("height", header_height + "px");
    $(".avatar").css("top", header_height / 2 - 140 + "px");
    scroll();
    $(window).resize(scroll).scroll(scroll);
    $('#navbar').scrollspy()

    var left_column_height = 0;
    var right_column_height = 0;
    var items = $('.article-container');
    for (var i = 0; i < items.length; i++) {
    if (left_column_height > right_column_height) {
        right_column_height+= items.eq(i).addClass('right').outerHeight(true);
    } else {
        left_column_height+= items.eq(i).addClass('left').outerHeight(true);
    }
}

    });