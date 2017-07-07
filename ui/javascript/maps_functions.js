/************************************
GET FACET TERMS IN RESULTS PAGE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This utilizes ajax to populate the list of terms in the facet category in the results page.
If the list is populated and then hidden, when it is re-activated, it fades in rather than executing the ajax call again.
 ************************************/
$(document).ready(function () {
    var popupStatus = 0;
    
    var langStr = getURLParameter('lang');
    var pipeline = 'maps';
    if (langStr == 'null') {
        var lang = '';
    } else {
        var lang = langStr;
    }
    var path = $('#path').text();
    var mapboxKey = $('#mapboxKey').text();
    
    //set hierarchical labels on load
    /*$('.hierarchical-facet').each(function(){
    var field = $(this).attr('id').split('_hier')[0];
    var title = $(this).attr('title');
    hierarchyLabel(field, title);
    });
    dateLabel();
    
    $("#backgroundPopup").on('click', function (event) {
    disablePopup();
    });*/
    
    /* INITIALIZE MAP */
    var q = '*:*';
    
    //baselayers
    var mb_physical = L.tileLayer(
    'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=' + mapboxKey, {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://mapbox.com">Mapbox</a>', id: 'mapbox.streets'
    });
    
    var osm = L.tileLayer(
    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'OpenStreetMap',
        maxZoom: 18
    });
    
    var map = new L.Map('mapcontainer', {
        center: new L.LatLng(0, 0),
        zoom: 4,
        layers:mb_physical
    });
    
    //add mintLayer from AJAX
    var overlay = L.geoJson.ajax(path + "query.geojson?q=" + q);
    
    var baseMaps = {
        'Topography': mb_physical,
        'Open Street Map': osm
    };
    
    var layerControl = L.control.layers(baseMaps).addTo(map);
    
    
    //zoom to groups on AJAX complete
    overlay.on('data:loaded', function () {
        markers = L.markerClusterGroup();
        layerControl.addOverlay(markers, 'Related Places');
        markers.addLayer(overlay);
        map.addLayer(markers);
        
        var group = new L.featureGroup([overlay]);
        map.fitBounds(group.getBounds());
    }.bind(this));
    
    overlay.on('click', function (e) {
        renderPopup(e);
    });
    
    //multiselect facets
    $('.multiselect').multiselect({
        buttonWidth: '250px',
        enableCaseInsensitiveFiltering: true,
        maxHeight: 250,
        buttonText: function (options, select) {
            if (options.length == 0) {
                return select.attr('title');
            } else if (options.length > 2) {
                return select.attr('title') + ': ' + options.length + ' selected';
            } else {
                var selected = '';
                options.each(function () {
                    selected += $(this).text() + ', ';
                });
                label = selected.substr(0, selected.length - 2);
                if (label.length > 20) {
                    label = label.substr(0, 20) + '...';
                }
                return select.attr('title') + ': ' + label;
            }
        },
        onChange: function (element, checked) {
            //if there are 0 selected checks in the multiselect, re-initialize ajax to populate list
            id = element.parent('select').attr('id');
            if ($('#' + id).val() == null) {
                var q = getQuery();
                var category = id.split('-select')[0];
                $.get(path + 'get_facets/', {
                    q: q, category: category, sort: 'index', lang: lang
                },
                function (data) {
                    $('#ajax-temp').html(data);
                    $('#' + id).html('');
                    $('#ajax-temp option').each(function () {
                        $(this).clone().appendTo('#' + id);
                    });
                    $("#" + id).multiselect('rebuild');
                });
            }
            if ($('#mapcontainer').length > 0) {
                //update map
                refreshMap();
            }
        }
    });
    
    //on open
    $('button.multiselect').on('click', function () {
        var q = getQuery();
        var id = $(this).parent('div').prev('select').attr('id');
        var category = id.split('-select')[0];
        $.get(path + 'get_facets/', {
            q: q, category: category, sort: 'index', lang: lang, pipeline: pipeline
        },
        function (data) {
            $('#ajax-temp').html(data);
            $('#' + id).html('');
            $('#ajax-temp option').each(function () {
                $(this).clone().appendTo('#' + id);
            });
            $("#" + id).multiselect('rebuild');
        });
    });
    
    $('#results').on('click', '.paging_div .page-nos .btn-toolbar .pagination a.pagingBtn', function (event) {
        var href = path + 'results_ajax/' + $(this).attr('href');
        $.get(href, {
        },
        function (data) {
            $('#results').html(data);
        });
        return false;
    });
    
    //clear query
    $('#results').on('click', 'h1 small #clear_all', function () {
        $('#results').html('');
        return false;
    });
    
    /***************************/
    //@Author: Adrian "yEnS" Mato Gondelle
    //@website: www.yensdesign.com
    //@email: yensamg@gmail.com
    //@license: Feel free to use it, but keep this credits please!
    /***************************/
    
    //disabling popup with jQuery magic!
    function disablePopup() {
        //disables popup only if it is enabled
        if (popupStatus == 1) {
            $("#backgroundPopup").fadeOut("fast");
            $('#category_hier-list').parent('div').attr('style', 'width: 192px;');
            $('#century_num-list').parent('div').attr('style', 'width: 192px;');
            popupStatus = 0;
        }
    }
    
    function getURLParameter(name) {
        return decodeURI(
        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
    }
    
    /*****
     * LEAFLET FUNCTIONS
     *****/
    function refreshMap() {
        var query = getQuery();
        url = path + "query.geojson?q=" + query + (lang.length > 0 ? '&lang=' + lang: '');
        
        layerControl.removeLayer(markers);
        map.removeLayer(markers);
        overlay.refresh(url);
    }
    
    /*****
     * Generate a popup for the various types of layers
     *****/
    function renderPopup(e) {
        var query = getQuery();
        query += ' AND ' + 'georef:"' + e.layer.feature.properties.georef + '"';
        var str = e.layer.feature.properties.type + ": <a href='#results' class='show_records' q='" + query + "'>" + e.layer.feature.properties.toponym + "</a> <a href='" + e.layer.feature.properties.gazetteer_uri + "' target='_blank'><span class='glyphicon glyphicon-new-window'/></a>";
        e.layer.bindPopup(str).openPopup();
        $('.show_records').on('click', function (event) {
            var query = $(this).attr('q');
            $.get(path + 'results_ajax/', {
                q: query,
                lang: lang
            },
            function (data) {
                $('#results').html(data);
            }).done(function () {
                $('div.thumbImage a').fancybox({ helpers: {
                        title: {
                            type: 'inside'
                        }
                    }
                });
            });
            return false;
        });
    }
});