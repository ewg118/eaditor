$(document).ready(function () {
	var image = $('#image-path').text();
	var id = $('#image-id').text();
	//call load_image function, which will wait until the image loads in the DOM before getting its height and width to initiate openlayers
	load_image(id, image);
	
	//activate slider image clicks to load large image in openlayers
	$('.page-image').click(function () {
		//first clear container div and annot div
		$('#image-container').html('');
		$('#annot').html('');
		
		//then destroy annotations before reloading
		anno.destroy();
		
		//reload
		var image = $(this).children('a').attr('href');
		var id = $(this).attr('id');
		load_image(id, image);
		return false;
	});
	
	//allow annotation when button is clicked
	/*$('#map-annotate-button').click(function () {
		annotate();
	});*/
});

function load_image(id, image) {
	var dimensions = new Array();
	$('<img/>').on("load", function () {
		dimensions[ "height"] = $(this).height();
		dimensions[ "width"] = $(this).width();
		render_map(id, image, dimensions);
	}).attr('src', image).appendTo('#image-container');
}

function render_map(id, image, dimensions) {
	
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
	
	//import annotations
	import_annotations(id);
}

function import_annotations(id) {
	var path = $('#display_path').text();
	var doc = $('#doc').text();
	$.get(path + 'get_annotations/', {
		facsimile: id, doc: doc
	},
	function (data) {
		var obj = $.parseJSON(data);
		$.each(obj, function (index, value) {
			anno.addAnnotation(value);
		});
	});
}

/*function annotate() {
	anno.activateSelector();
	anno.addHandler('onAnnotationCreated', function (annotation) {
		//coordinates	
		var ulx = annotation.shapes[0].geometry.x;
		var lrx = annotation.shapes[0].geometry.x + annotation.shapes[0].geometry.width;
		var uly = annotation.shapes[0].geometry.y;
		var lry = annotation.shapes[0].geometry.y - annotation.shapes[0].geometry.height;
		obj = {ulx:ulx, lrx:lrx, uly:uly, lry:lry, desc:annotation.text};
		//console.log(annotation);
	});
}*/