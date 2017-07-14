function initialize_timemap(id, path) {
    var path = $('#path').text();
    var url = path + "api/get?id=" + id + "&format=json&model=timemap";
    var datasets = new Array();
    
    //first dataset
    datasets.push({
        id: 'dist',
        title: "Distribution",
        type: "json",
        options: {
            url: url
        }
    });
    
    var tm;
    tm = TimeMap.init({
        mapId: "map", // Id of map div element (required)
        timelineId: "timeline", // Id of timeline div element (required)
        options: {
            eventIconPath: path + "images/timemap/"
        },
        datasets: datasets,
        bandIntervals:[
        Timeline.DateTime.YEAR,
        Timeline.DateTime.DECADE]
    });
}

function initialize_map(id, path) {
    var mapboxKey = $('#mapboxKey').text();
    
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
        layers: mb_physical
    });
    
    //add mintLayer from AJAX
    var overlay = L.geoJson.ajax(id + ".geojson");
    
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
}

/*****
 * LEAFLET FUNCTIONS
 *****/

/*****
 * Generate a popup for the various types of layers
 *****/
function renderPopup(e) {
    var str = "<h4>" + e.layer.feature.properties.toponym + " <a href='" + e.layer.feature.properties.gazetteer_uri + "' target='_blank'><span class='glyphicon glyphicon-new-window'/></a></h4>";
    
    if (e.layer.feature.properties.relatedComponent.length > 0) {
        str += '<div><b>Related Components</b>';
        str += '<ul>';
        $.each(e.layer.feature.properties.relatedComponent, function (key, value) {
            str += "<li><a href='" + value.uri + "'>" + value.title + '</a></li>';
        });
        str += '</ul></div>';
    }
    
    e.layer.bindPopup(str).openPopup();
}