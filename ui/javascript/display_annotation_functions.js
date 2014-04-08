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
		
		//reset selected class
		$('img.selected').removeAttr('class');
		$(this).children('img').attr('class','selected');
		
		//then destroy annotations before reloading
		anno.destroy();
		
		//reload
		var image = $(this).attr('href');
		var id = $(this).attr('id');
		load_image(id, image);
		
		//enable/disable prev/next page links
		if (id == $('#first-page').text()) {
			$('#prev-page').attr('class','disabled');
			$('#next-page').removeAttr('class');
		}
		if (id == $('#last-page').text()) {
			$('#next-page').attr('class','disabled');
			$('#prev-page').removeAttr('class');
		}	
		//alter goto page dropdown
		$('#goto-page').val(id);		
		return false;
	});
	
	/* navigation pagination */
	$('#prev-page').click(function () {
		var current_id = $('img.selected').parent('.page-image').attr('id');
		var prev_id = $('#' + current_id).prev('.page-image').attr('id');
		if (prev_id != null){
			//first clear container div and annot div
			$('#image-container').html('');
			$('#annot').html('');
			
			//reset selected class
			$('img.selected').removeAttr('class');
			$('#' + prev_id).children('img').attr('class','selected');
			
			//then destroy annotations before reloading
			anno.destroy();
			
			//reload
			var image = $('#' + prev_id).attr('href');
			var id = $('#' + prev_id).attr('id');
			load_image(id, image);
		}	
		//enable/disable link
		if (prev_id == $('#first-page').text()) {
			$('#prev-page').attr('class','disabled');
			$('#next-page').removeAttr('class');
		}
		//alter goto page dropdown
		$('#goto-page').val(prev_id);
		return false;
	});
	$('#next-page').click(function () {
		var current_id = $('img.selected').parent('.page-image').attr('id');
		var next_id = $('#' + current_id).next('.page-image').attr('id');
		if (next_id != null){
			//first clear container div and annot div
			$('#image-container').html('');
			$('#annot').html('');
			
			//reset selected class
			$('img.selected').removeAttr('class');
			$('#' + next_id).children('img').attr('class','selected');
			
			//then destroy annotations before reloading
			anno.destroy();
			
			//reload
			var image = $('#' + next_id).attr('href');
			var id = $('#' + next_id).attr('id');
			load_image(id, image);
		}
		//enable/disable link
		if (next_id == $('#last-page').text()) {
			$('#next-page').attr('class','disabled');
			$('#prev-page').removeAttr('class');
		}		
		//alter goto page dropdown
		$('#goto-page').val(next_id);		
		return false;
	});
	
	/* go to page dropdown */
	$('#goto-page').change(function(){
		var id = $(this).val();
		
		//first clear container div and annot div
		$('#image-container').html('');
		$('#annot').html('');
		
		//reset selected class
		$('img.selected').removeAttr('class');
		$('#' + id).children('img').attr('class','selected');
		
		//then destroy annotations before reloading
		anno.destroy();
		
		//reload
		var image = $('#' + id).attr('href');
		load_image(id, image);
			
		//enable/disable link
		if (id == $('#first-page').text()) {
			$('#prev-page').attr('class','disabled');
			$('#next-page').removeAttr('class');
		} else if (id == $('#last-page').text()) {
			$('#next-page').attr('class','disabled');
			$('#prev-page').removeAttr('class');
		} else {
			$('#next-page').removeAttr('class');
			$('#prev-page').removeAttr('class');
		}
		return false;
	});
	
	/* image scroller */
	$('#left-scroll').on('click', function (event) {
		$('#slider-thumbs').animate({
			scrollLeft: - 500
		},
		1000)
	});
	$('#right-scroll').on('click', function (event) {
		$('#slider-thumbs').animate({
			scrollLeft: 500
		},
		1000)
	});
});

function load_image(id, image) {
	var dimensions = new Array();
	$('<img/>').on("load", function () {
		dimensions[ "height"] = this.naturalHeight;
		dimensions[ "width"] = this.naturalWidth;
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