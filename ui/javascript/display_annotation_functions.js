$(document).ready(function () {
	var image = $('#image-path').text();
	//call load_image function, which will wait until the image loads in the DOM before getting its height and width to initiate openlayers
	load_image(image);
	
	//activate slider image clicks to load large image in openlayers
	$('.page-image').click(function () {
		//first clear container div and annot div
		$('#image-container').html('');
		$('#annot').html('');
		var image = $(this).children('a').attr('href');
		load_image(image);
		return false;
	});
});

function load_image(image) {
	var dimensions = new Array();
	$('<img/>').on("load", function () {
		dimensions[ "height"] = $(this).height();
		dimensions[ "width"] = $(this).width();
		render_map(image, dimensions);
	}).attr('src', image).appendTo('#image-container');
}

function render_map(image, dimensions) {
	var height = + dimensions[ "height"];
	var width = + dimensions[ "width"];
	
	//get ratio between height and width and set bounds
	if (height > width) {
		var ratio = height / width;
		var bounds = new Array(- 1, - Math.abs(ratio), 1, ratio);
	} else {
		var ratio = width / height;
		var bounds = new Array(- Math.abs(ratio), - 1, ratio, 1);
	}
	//instantiate map
	var map = new OpenLayers.Map('annot', {
		numZoomLevels: 3, units: "pixels", isBaseLayer: true
	});
	var baseLayer = new OpenLayers.Layer.Image('image', image, new OpenLayers.Bounds(bounds), new OpenLayers.Size(600 * ratio, 600));
	
	//add baseLayer, zoom to extent
	map.addLayer(baseLayer);
	map.zoomToMaxExtent();
	
	//handle annotations
	anno.makeAnnotatable(map);
	/*anno.activateSelector();
	anno.addHandler('onAnnotationCreated', function (annotation) {
	console.log(annotation);
	});*/
	/*$("#map-annotate-button").livequery('click', function (event) {
	anno.activateSelector();
	});*/
}

function annotate() {
	anno.activateSelector();
	anno.addHandler('onAnnotationCreated', function (annotation) {
		console.log(annotation);
	});
}