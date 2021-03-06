$(document).ready(function () {
    //initialize map, if applicable
    if ($('#mapcontainer').length > 0) {
        var id = $('title').attr('id');
        var path = $('#path').text();
        //initialize_timemap(id, path);
        initialize_map(id, path);
    }    
    
    if ($(".thumbImage").length > 0) {
        //popup non-IIIF images on EAD pages
        $(".thumbImage").fancybox({ helpers: {
                title: {
                    type: 'inside'
                }
            }
        });
    }
    
    //show/hide sections
    $('.toggle-button').click(function () {
        var div = $(this).attr('id').split('-')[1];
        $('#' + div).toggle();
        
        //replace minus with plus and vice versa
        var span = $(this).children('span');
        if (span.attr('class').indexOf('right') > 0) {
            span.removeClass('glyphicon-triangle-right');
            span.addClass('glyphicon-triangle-bottom');
        } else {
            span.removeClass('glyphicon-triangle-bottom');
            span.addClass('glyphicon-triangle-right');
        }
        return false;
    });
    
    //IIIF in popup on EAD pages
    if ($('.iiif-image').length > 0) {
        $('.iiif-image').fancybox({
            beforeShow: function () {
                var manifest = this.element.attr('manifest');
                //remove and replace #iiif-container, if different or new
                if (manifest != $('#manifest').text()) {
                    $('#iiif-container').remove();
                    $(".iiif-container-template").clone().removeAttr('class').attr('id', 'iiif-container').appendTo("#iiif-window");
                    $('#manifest').text(manifest);
                    render_image(manifest);
                }
            },
            helpers: {
                title: {
                    type: 'inside'
                }
            }
        });
    }
    
    
    //initialize Leaflet IIIF for MODS record pages
    if ($('#info-json').length > 0) {
        var manifest = $('#info-json').text();
        render_image(manifest);
    }
    
    function render_image(manifest) {
        var iiifImage = L.map('iiif-container', {
            center:[0, 0],
            crs: L.CRS.Simple,
            zoom: 0
        });
        
        // Grab a IIIF manifest
        $.getJSON(manifest, function (data) {
            //determine where it is a collection or image manifest
            if (data[ '@context'] == 'http://iiif.io/api/image/2/context.json' || data[ '@context'] == 'http://library.stanford.edu/iiif/image-api/1.1/context.json') {
                L.tileLayer.iiif(manifest).addTo(iiifImage);
            } else if (data[ '@context'] == 'http://iiif.io/api/presentation/2/context.json') {
                var iiifLayers = {
                };
                
                // For each image create a L.TileLayer.Iiif object and add that to an object literal for the layer control
                $.each(data.sequences[0].canvases, function (_, val) {
                    iiifLayers[val.label] = L.tileLayer.iiif(val.images[0].resource.service[ '@id'] + '/info.json');
                });
                // Add layers control to the map
                L.control.layers(iiifLayers).addTo(iiifImage);
                
                // Access the first Iiif object and add it to the map
                iiifLayers[Object.keys(iiifLayers)[0]].addTo(iiifImage);
            }
        });
    }
});