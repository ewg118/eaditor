/************************************
GET FACET TERMS IN RESULTS PAGE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This utilizes ajax to populate the list of terms in the facet category in the results page.  
If the list is populated and then hidden, when it is re-activated, it fades in rather than executing the ajax call again.
************************************/
$(document).ready(function() {
	var popupStatus = 0;
	var langStr = getURLParameter('lang');
	var pipeline = 'results';
	var path = '../';
	if (langStr == 'null'){
		var lang = '';
	} else {
		var lang = langStr;
	}
	
	//set date label if there is a date facet
	if ($('#century_num_link').length != 0){
		dateLabel();
	}
	
	//set hierarchical labels on load
	$('.hierarchical-facet').each(function(){
		var field = $(this).attr('id').split('_hier')[0];
		var title = $(this).attr('title');
		hierarchyLabel(field, title);
	});
	
	$("#backgroundPopup").click(function() {
		disablePopup();
	});
	
	/***** SEARCH *****/
	$('#search_button') .click(function () {
		var q = getQuery();
		$('#facet_form_query').attr('value', q);
	});
	
	//multiselect facets
	$('.multiselect').multiselect({
		buttonWidth: '250px',
		enableFiltering: true,
		maxHeight: 250,
		buttonText: function (options, select) {
			if (options.length == 0) {
				return select.attr('title') + ' <b class="caret"></b>';
			} else if (options.length > 2) {
				return select.attr('title') + ': ' + options.length + ' selected <b class="caret"></b>';
			} else {
				var selected = '';
				options.each(function () {
					selected += $(this).text() + ', ';
				});
				label = selected.substr(0, selected.length - 2);
				if (label.length > 20) {
					label = label.substr(0, 20) + '...';
				}
				return select.attr('title') + ': ' + label + ' <b class="caret"></b>';
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
	
	/***************** DRILLDOWN HIERARCHICAL FACETS ********************/
	/*$('.hierarchical-facet').hover(function () {
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
			$.get('get_hier', {
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
			$.get('get_hier', {
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
		} else {
			$('#' + field + '_hier_link').attr('title', title);
			$('#' + field + '_hier_link').children('span:nth-child(2)').html(title);
		}
		
	});*/
	
	/***************** DRILLDOWN FOR DATES ********************/
	/*$('#century_num_link').hover(function () {
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
		var list_id = $(this) .attr('id').split('_link')[0] + '-list';
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
					q: q, century: century, pipeline: pipeline
				},
				function (data) {
					$('#decades-temp').html(data);
					$('#decades-temp li').each(function(){
						$(this).clone().appendTo('#century_' + century + '_list');
					});
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
	});
	//uncheck child decades when century is unchecked
	$('.century_checkbox').livequery('click', function (event) {
		if ($(this).not(':checked')) {
			$(this).parent('li').children('ul').children('li').children('.decade_checkbox').attr('checked', false);
		}
		//set label
		dateLabel();
	});	
	*/
	

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
			$('#century_num-list') .parent('div').attr('style', 'width: 192px;');
			popupStatus = 0;		
		}
	}
	
	function getURLParameter(name) {
	    return decodeURI(
	        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
	    );
	}

});