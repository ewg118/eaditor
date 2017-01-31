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
	
	//initialize map
	var style = new OpenLayers.Style({
		pointRadius: "${radius}",
		fillColor: "#0000ff",
		fillOpacity: 0.8,
		strokeColor: "#000072",
		strokeWidth: 2,
		strokeOpacity: 0.8
	},
	{
		context: {
			radius: function (feature) {
				return Math.min(feature.attributes.count, 7) + 3;
			}
		}
	});
	var placeLayer = new OpenLayers.Layer.Vector("Place", {
		styleMap: style,
		eventListeners: {
			'loadend': kmlLoaded
		},
		strategies:[
		new OpenLayers.Strategy.Fixed(),
		new OpenLayers.Strategy.Cluster()],
		protocol: new OpenLayers.Protocol.HTTP({
			url: path + "query.kml?q=" + q + (lang.length > 0? '&lang=' + lang: ''),
			format: new OpenLayers.Format.KML({
				extractStyles: false,
				extractAttributes: true
			})
		})
	});
	
	var map = new OpenLayers.Map('mapcontainer', {
		controls:[
		new OpenLayers.Control.PanZoomBar(),
		new OpenLayers.Control.Navigation(),
		new OpenLayers.Control.ScaleLine(),
		new OpenLayers.Control.LayerSwitcher({
			'ascending': true
		})]
	});
	
	var googlePhys = new OpenLayers.Layer.Google("Google Physical", {
		type: google.maps.MapTypeId.TERRAIN
	});
	map.addLayer(googlePhys);
	map.addLayer(placeLayer);
	
	//zoom to extent of world
	map.zoomTo('2');
	
	//enable events for place selection
	SelectControl = new OpenLayers.Control.SelectFeature([placeLayer], {
		clickout: true,
		multiple: false,
		hover: false
	});
	
	
	map.addControl(SelectControl);
	
	SelectControl.activate();
	
	placeLayer.events.on({
		"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect
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
					$('#' + id) .html('');
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
			$('#' + id) .html('');
			$('#ajax-temp option').each(function () {
				$(this).clone().appendTo('#' + id);
			});
			$("#" + id).multiselect('rebuild');
		});
	});
	
	function refreshMap() {
		var query = getQuery();
		
		//refresh maps.
		var placeQuery = path + "query.kml?q=" + query + (lang.length > 0? '&lang=' + lang: '');
		placeLayer.loaded = false;
		//the refresh will force it to get the new KML data//
		placeLayer.refresh({
			force: true, url: placeQuery
		});
		placeLayer.setVisibility(true);
		map.zoomToExtent(placeLayer.getDataExtent());
	}
	
	$('#results') .on('click', '.paging_div .page-nos .btn-toolbar .pagination a.pagingBtn', function (event) {
		var href = path + 'results_ajax/' + $(this) .attr('href');
		$.get(href, {
		},
		function (data) {
			$('#results') .html(data);
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
			$('#category_hier-list') .parent('div').attr('style', 'width: 192px;');
			$('#century_num-list') .parent('div').attr('style', 'width: 192px;');
			popupStatus = 0;
		}
	}
	
	/********************
	OpenLayers functions for object collections
	********************/
	function kmlLoaded() {
		map.zoomToExtent(placeLayer.getDataExtent());
	}
	
	function onPopupClose(evt) {
		map.removePopup(map.popups[0]);
	}
	
	function onFeatureSelect(event) {
		var q = getQuery();
		
		var name = this.name;
		var message = '';
		var place_uris = new Array();
		var place_names = new Array();
		if (event.feature.cluster.length > 12) {
			message = '<div style="font-size:10px">' + event.feature.cluster.length + ' ' + name + 's found at this location';
			for (var i in event.feature.cluster) {
				place_uris.push(event.feature.cluster[i].attributes[ 'description']);
				place_names.push(event.feature.cluster[i].attributes[ 'name']);
			}
		} else if (event.feature.cluster.length > 1 && event.feature.cluster.length <= 12) {
			message = '<div style="font-size:10px;width:300px;">' + event.feature.cluster.length + ' ' + name + 's found at this location: ';
			for (var i in event.feature.cluster) {
				place_uris.push(event.feature.cluster[i].attributes[ 'description']);
				place_names.push(event.feature.cluster[i].attributes[ 'name']);
				message += event.feature.cluster[i].attributes[ 'name'];
				if (i < event.feature.cluster.length - 1) {
					message += ', ';
				}
			}
		} else if (event.feature.cluster.length == 1) {
			place_uris.push(event.feature.cluster[0].attributes[ 'description']);
			place_names.push(event.feature.cluster[0].attributes[ 'name']);
			message = '<div style="font-size:10px">' + name + ' of ' + event.feature.cluster[0].attributes[ 'name'];
		}
		
		//assemble the place query
		var place_query = '';
		if (event.feature.cluster.length > 1) {
			place_query += '(';
			for (var i in place_uris) {
				//place_query += name + '_uri:"' + place_uris[i] + '"';
				place_query += 'georef:"' + place_uris[i] + '"';
				if (i < place_uris.length - 1) {
					place_query += ' OR ';
				}
			}
			place_query += ')';
		} else {
			place_query = 'georef:"' + place_uris[0] + '"';
			//place_query = name + '_uri:"' + place_uris[0] + '"';
		}
		var query = q + ' AND ' + place_query;
		
		message += '.<br/><br/>';
		message += "<a href='#results' class='show_records' q='" + query + "'>View</a> records that meet the search criteria from " + (event.feature.cluster.length > 1? 'these ' + name + 's': 'this ' + name) + '.';
		message += '</div>';
		
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
		
		$('.show_records').on('click', function (event) {
			var query = $(this).attr('q');
			$.get(path + 'results_ajax/', {
				q: query,
				lang: lang
			},
			function (data) {
				$('#results') .html(data);
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
	
	function onFeatureUnselect(event) {
		map.removePopup(map.popups[0]);
	}
	
	function getURLParameter(name) {
		return decodeURI(
		(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
	}
});