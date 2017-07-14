$(document).ready(function () {
    if ($('#mapcontainer').html().length == 0) {
        var id = $('title').attr('id');
        var path = $('#path').text();
        //initialize_timemap(id, path);
        initialize_map(id, path);
    }
    
    $(".thumbImage").fancybox({ helpers: {
            title: {
                type: 'inside'
            }
        }
    });
});