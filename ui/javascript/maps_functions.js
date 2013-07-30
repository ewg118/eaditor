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
	if (langStr == 'null'){
		var lang = '';
	} else {
		var lang = langStr;
	}
	
	
	//set hierarchical labels on load
	$('.hierarchical-facet').each(function(){
		var field = $(this).attr('id').split('_hier')[0];
		var title = $(this).attr('title');
		hierarchyLabel(field, title);
	});
	dateLabel();
	
	$("#backgroundPopup").livequery('click', function (event) {
		disablePopup();
	});
	
	/* INITIALIZE MAP */
	var q = '*:*';
	//alert(q);
	
	//initialize map
	var style = new OpenLayers.Style({
		pointRadius: "${radius}",
		fillColor: "#0000ff",
		fillOpacity: 0.8,
		strokeColor: "#000072",
		strokeWidth: 2,
		strokeOpacity: 0.8
	}, {
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
			url: "../query.kml?q=" + q + (lang.length > 0 ? '&lang=' + lang : ''),
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
	
	var googlePhys = new OpenLayers.Layer.Google("Google Physical",{type: google.maps.MapTypeId.TERRAIN});
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
	
	//enable multiselect
	$(".multiselect").multiselect({
		minWidth: 'auto',
		header: '<a class="ui-multiselect-none" href="#"><span class="ui-icon ui-icon-closethick"/><span>Uncheck all</span></a>',
		create: function () {
			var title = $(this).attr('title');
			var array_of_checked_values = $(this).multiselect("getChecked").map(function () {
				return this.value;
			}).get();
			var length = array_of_checked_values.length;
			
			if (length > 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + length + ' selected');
			} else if (length > 0 && length <= 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + array_of_checked_values.join(', '));
			} else if (length == 0) {
				$(this).next('button').children('span:nth-child(2)').text(title);
			}
		},
		beforeopen: function () {
			var id = $(this) .attr('id');
			var q = getQuery();
			var category = id.split('-select')[0];
			
			$.get('../get_facets/', {
				q: q, category: category, sort: 'index', lang: lang, pipeline: pipeline
			},
			function (data) {
				$('#ajax-temp').html(data);
				$('#' + id) .html('');
				$('#ajax-temp option').each(function(){
					$(this).clone().appendTo('#' + id);
				});
					$("#" + id).multiselect('refresh');
			});
		},
		click: function () {
			var title = $(this).attr('title');
			var id = $(this) .attr('id');
			var array_of_checked_values = $(this).multiselect("getChecked").map(function () {
				return this.value;
			}).get();
			var length = array_of_checked_values.length;
			if (length > 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + length + ' selected');
			} else if (length > 0 && length <= 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + array_of_checked_values.join(', '));
			} else if (length == 0){
				$(this).next('button').children('span:nth-child(2)').text(title);
			}

			//refresh dynamically 
			var q = getQuery();
			if (q.length > 0) {
				var category = id.split('-select')[0];
				$.get('../get_facets/', {
					q: q, category: category, sort: 'index', lang: lang, pipeline: pipeline
				},
				function (data) {
					$('#ajax-temp').html(data);
					$('#' + id) .html('');
					$('#ajax-temp option').each(function(){
						$(this).clone().appendTo('#' + id);
					});
					$("#" + id).multiselect('refresh');				
				});
			}
			
			if ($('#mapcontainer').length > 0) {
				//update map
				refreshMap();
			}
		},
		uncheckAll: function () {	
			//reset title
			var title = $(this).attr('title');
			$(this).next('button').children('span:nth-child(2)').text(title);	
			
			var id = $(this) .attr('id');
			q = getQuery();
			var category = id.split('-select')[0];
			$.get('../get_facets/', {
				q: q, category: category, sort: 'index', lang: lang, pipeline: pipeline
			},
			function (data) {
				$('#' + id) .attr('new_query', '');
				$('#' + id) .html(data);
				$('#' + id).multiselect('refresh');
			});
			
			if ($('#mapcontainer').length > 0) {
				//update map
				refreshMap();
			}
		}
	});
	//.multiselectfilter();
	
	function refreshMap() {
		var query = getQuery();
		
		//refresh maps.
		var placeQuery = "../query.kml?q=" + query + (lang.length > 0 ? '&lang=' + lang : '');
		placeLayer.loaded = false;		
		//the refresh will force it to get the new KML data//
		placeLayer.refresh({
			force: true, url: placeQuery
		});
		placeLayer.setVisibility(true);
		map.zoomToExtent(placeLayer.getDataExtent());
	}
	
	$('a.pagingBtn') .livequery('click', function (event) {
		var href = '../results_ajax/' + $(this) .attr('href');
		$.get(href, {
		},
		function (data) {
			$('#results') .html(data);
		});
		return false;
	});
	
	//clear query
	$('#clear_all').livequery('click', function (event) {
		$('#results').html('');
		return false;
	});
	
	/***************** DRILLDOWN HIERARCHICAL FACETS ********************/
	$('.hierarchical-facet').hover(function () {
		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all ui-state-focus');
	},
	function () {
		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all');
	});	
	
	$('.hier-close') .click(function () {
		disablePopup();
		return false;
	});	
	
	$('.hierarchical-facet').click(function () {
		if (popupStatus == 0) {
			$("#backgroundPopup").fadeIn("fast");
			popupStatus = 1;
		}
		var list_id = $(this) .attr('id').split('_link')[0] + '-list';
		var field = $(this) .attr('id').split('_hier')[0];
		var q = getQuery();
		if ($('#' + list_id).html().indexOf('<li') < 0) {
			$.get('../get_hier', {
				q: q, field: field, prefix: 'L1', fq: '*', section: 'collection', link: '', lang: lang
			},
			function (data) {
				$('#' + list_id) .html(data);
			});
		}
		$('#' + list_id).parent('div').attr('style', 'width: 192px;display:block;');
		return false;
	});
	
	//expand category when expand/compact image pressed
	$('.expand_category') .livequery('click', function (event) {
		var fq = $(this).next('input').val();
		var list = $(this) .attr('id').split('__')[0].split('|')[1] + '__list';
		var field = $(this).attr('field');
		var prefix = $(this).attr('next-prefix');
		var q = getQuery();
		var section = $(this) .attr('section');
		var link = $(this) .attr('link');
		if ($(this) .children('img') .attr('src') .indexOf('plus') >= 0) {
			$.get('../get_hier', {
				q: q, field:field, prefix: prefix, fq: '"' +fq + '"', link: link, section: section, lang: lang
			},
			function (data) {
				$('#' + list) .html(data);
			});
			$(this) .parent('li') .children('.' + field + '_level') .show();
			$(this) .children('img') .attr('src', $(this) .children('img').attr('src').replace('plus', 'minus'));
		} else {
			$(this) .parent('li') .children('.' + field + '_level') .hide();
			$(this) .children('img') .attr('src', $(this) .children('img').attr('src').replace('minus', 'plus'));
		}
	});
	
	//remove all ancestor or descendent checks on uncheck
	$('.h_item input') .livequery('click', function (event) {
		var field = $(this).closest('.ui-multiselect-menu').attr('id').split('-')[0];
		var title = $('.' + field + '-multiselect-checkboxes').attr('title');
		
		var count_checked = 0;
		$('#' + field + '_hier-list input:checked').each(function () {
			count_checked++;
		});
		
		if (count_checked > 0) {
			hierarchyLabel(field, title);
			refreshMap();
		} else {
			$('#' + field + '_hier_link').attr('title', title);
			$('#' + field + '_hier_link').children('span:nth-child(2)').html(title);
		}
		
	});
	
	/***************** DRILLDOWN FOR DATES ********************/
	$('#century_num_link').hover(function () {
		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all ui-state-focus');
	},
	function () {
		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all');
	});
	
	$('.century-close').livequery('click', function (event) {
		disablePopup();
	});
	
	$('#century_num_link').livequery('click', function (event) {
		if (popupStatus == 0) {
			$("#backgroundPopup").fadeIn("fast");
			popupStatus = 1;
		}
		
		var q = getQuery();
		var pipeline = $('#pipeline').text();
		var list_id = $(this) .attr('id').split('_link')[0] + '-list';
		$.get('../get_centuries', {
			q: q, pipeline: pipeline
		},
		function (data) {
			$('#century_num-list').html(data);
		});
		
		$('#' + list_id).parent('div').attr('style', 'width: 192px;display:block;');
	});
	
	$('.expand_century').livequery('click', function (event) {
		var century = $(this).attr('century');
		if (century < 0) {
			century = "\\" + century;
		}
		//var q = $(this).attr('q');
		var q = getQuery();
		var expand_image = $(this).children('img').attr('src');
		//hide list if it is expanded
		if (expand_image.indexOf('minus') > 0) {
			$(this).children('img').attr('src', expand_image.replace('minus', 'plus'));
			$('#century_' + century + '_list') .hide();
		} else {
			$(this).children('img').attr('src', expand_image.replace('plus', 'minus'));
			//perform ajax load on first click of expand button
			if ($(this).parent('li').children('ul').html().indexOf('<li') < 0) {
				$.get('../get_decades/', {
					q: q, century: century
				},
				function (data) {
					$('#century_' + century + '_list').html(data);
				});
			}
			$('#century_' + century + '_list') .show();
		}
	});
	
	//check parent century box when a decade box is checked
	$('.decade_checkbox').livequery('click', function (event) {
		if ($(this) .is(':checked')) {
			$(this) .parent('li').parent('ul').parent('li') .children('input') .attr('checked', true);
		}
		//set label
		dateLabel();
		refreshMap();
	});
	//uncheck child decades when century is unchecked
	$('.century_checkbox').livequery('click', function (event) {
		if ($(this).not(':checked')) {
			$(this).parent('li').children('ul').children('li').children('.decade_checkbox').attr('checked', false);
		}
		//set label
		dateLabel();
		refreshMap();
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
		message += "<a href='#results' class='show_coins' q='" + query + "'>View</a> records that meet the search criteria from " + (event.feature.cluster.length > 1? 'these ' + name + 's': 'this ' + name) + '.';
		message += '</div>';
		
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
		
		$('.show_coins').livequery('click', function (event) {
			var query = $(this).attr('q');
			$.get('../results_ajax/', {
				q: query,
				lang: lang
			},
			function (data) {
				$('#results') .html(data);
			});
			return false;
		});
	}
	
	function onFeatureUnselect(event) {
		map.removePopup(map.popups[0]);
	}
	
	function getURLParameter(name) {
	    return decodeURI(
	        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
	    );
	}
});
