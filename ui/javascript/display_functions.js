$(document).ready(function () {    
    $('#mapButton').click(function () {
        $('#tabs a:last').tab('show');
        //only initialize map if there is zero-length content within #mapcontainer
        if ($('#mapcontainer').html().length == 0) {
            var id = $('title').attr('id');
            var path = $('#path').text();
            //initialize_timemap(id, path);
            initialize_map(id, path);
        }
    });
    
    $(".thumbImage").fancybox({ helpers: {
            title: {
                type: 'inside'
            }
        }
    });
});