/*******************
FUNCTIONS USED IN FACET-BASED PAGES: BROWSE, COLLECTION, AND MAPS
********************/
function getQuery() {
	//get categories
	query = new Array();
	
	//get non-facet fields that may have been passed from search
	var query_terms = $('#facet_form_query').attr('value').split(' AND ');
	var non_facet_terms = new Array();
	for (i in query_terms) {
		if (query_terms[i].indexOf('_facet') < 0 && query_terms[i].indexOf('dob_num') < 0 && query_terms[i] != '*:*') {
			non_facet_terms.push(query_terms[i]);
		}
	}
	if (non_facet_terms.length > 0) {
		query.push(non_facet_terms.join(' AND '));
	}
	
	//hierarchical facets
	$('.hierarchical-list').each(function () {
		var field = $(this).attr('id').split('-list')[0];
		var categories = new Array();
		$(this).find('input:checked') .each(function () {
			if ($(this) .parent('.h_item') .html() .indexOf('category_level') < 0 || $(this) .parent('.h_item') .children('ul') .html() .indexOf('<li') < 0 || $(this) .parent('.h_item') .children('.category_level').find('input:checked').length == 0) {
				segment = new Array();
				$(this) .parents('.h_item').each(function () {
					segment.push('+"' + $(this).children('input').val() + '"');
				});
				var joined = field + ':(' + segment.join(' ') + ')';
				categories.push(joined);
			}
		});
		//if the categories array is not null, establish the category query string
		if (categories[0] != null) {
			if (categories.length > 1) {
				query.push('(' + categories.join(' OR ') + ')');
			} else {
				query.push(categories[0]);
			}
		}
	});
	
	//get century/decades
	var date = getDate();
	if (date.length > 0) {
		query.push(getDate());
	}
	
	$('select.multiselect').each(function () {
		var val = $(this).val();
		var facet = $(this).attr('id').split('-')[0];
		if (val != null) {
			segments = new Array();
			for (var i = 0; i < val.length; i++) {
				segments.push(facet + ':"' + val[i] + '"');
			}
			if (segments.length > 1) {
				query.push('(' + segments.join(' OR ') + ')');
			} else {
				query.push(segments[0]);
			}
		}
	});
	
	//keyword search (only implemented on collection page)
	if ($('#keyword').length > 0) {
		if ($('#keyword').val().length > 0) {
			query.push($('#keyword').val());
		}
	}
	
	//date range search (only implemented on collection page)
	if ($('#from_date').length > 0 || $('#to_date').length > 0) {
		if ($('#from_date') .val().length > 0 || $('#to_date') .val().length > 0) {
			var string = '';
			string += 'year_num:';
			var from_date = $('#from_date') .val().length > 0? $('#from_date') .val(): '*';
			var from_era = $('#from_era') .val() == 'minus'? '-': '';
			
			var to_date = $('#to_date') .val().length > 0? $('#to_date') .val(): '*';
			var to_era = $('#to_era') .val() == 'minus'? '-': '';
			
			string += '[' + (from_date == '*'? '': from_era) + from_date + ' TO ' + (to_date == '*'? '': to_era) + to_date + ']';
			query.push(string);
		}
	}
	
	//set the value attribute of the q param to the query assembled by javascript
	
	if (query.length > 0) {
		return query.join(' AND ');
	} else {
		return '*:*';
	}
}

//function for assembling the Lucene syntax string for querying on centuries and decades
function getDate() {
	var date_array = new Array();
	$('.century_checkbox:checked').each(function () {
		var val = $(this).val();
		if (val < 0) {
			val = '\\' + val;
		}
		var century = 'century_num:' + val;
		var decades = new Array();
		$(this).parent('li').children('ul').children('li').children('.decade_checkbox:checked').each(function () {
			var dval = $(this).val();
			if (dval < 0) {
				dval = '\\' + dval;
			}
			decades.push('decade_num:' + dval);
		});
		var decades_concat = '';
		if (decades.length > 1) {
			decades_concat = '(' + decades.join(' OR ') + ')';
			date_array.push(decades_concat);
		} else if (decades.length == 1) {
			date_array.push(decades[0]);
		} else {
			date_array.push(century);
		}
	});
	var date_query;
	if (date_array.length > 1) {
		date_query = '(' + date_array.join(' OR ') + ')'
	} else if (date_array.length == 1) {
		date_query = date_array[0];
	} else {
		date_query = '';
	}
	return date_query;
};

function dateLabel() {	
	var title = $('#century_num-btn').attr('title');
	if (title.indexOf(':') > 0){
		title = title.split(':')[0];
	}
	dates = new Array();
	$('.century_checkbox:checked').each(function () {
		if ($(this).parent('li').children('ul').children('li').children('.decade_checkbox:checked').length == 0) {
			var century = Math.abs($(this).val());
			var suffix;
			switch (century % 10) {
				case 1:
				suffix = 'st';
				break;
				case 2:
				suffix = 'nd';
				break;
				case 3:
				suffix = 'rd';
				break;
				default:
				suffix = 'th';
			}
			label = century + suffix;
			if ($(this).val() < 0) {
				label += ' B.C.';
			}
			dates.push(label);
		}
		$(this).parent('li').children('ul').children('li').children('.decade_checkbox:checked').each(function () {
			dates.push($(this).val());
		});
	});
	if (dates.length > 3) {
		var date_string = title + ': ' + dates.length + ' selected';
	} else if (dates.length > 0 && dates.length <= 3) {
		var date_string = title + ': ' + dates.join(', ');
	} else if (dates.length == 0) {
		var date_string = title;
	}
	//set labels
	$('#century_num-btn').attr('title', date_string);
	$('#century_num-btn').children('span:nth-child(2)').text(date_string);
}

function hierarchyLabel(field, title) {
	categories = new Array();
	$('#' + field + '_hier-list input:checked') .each(function () {
		if ($(this) .parent('.h_item') .html() .indexOf('category_level') < 0 || $(this) .parent('.h_item') .children('ul') .html() .indexOf('<li') < 0 || $(this) .parent('.h_item') .children('.category_level').find('input:checked').length == 0) {
			segment = new Array();
			$(this) .parents('.h_item').each(function () {
				segment.push($(this).children('input').val().split('|')[1]);
			});
			var joined = segment.reverse().join('--');
			categories.push(joined);
			if (categories.length > 0 && categories.length <= 3) {
				$('#' + field + '_hier_link').attr('title', title + ': ' + categories.join(', '));
				$('#' + field + '_hier_link').children('span:nth-child(2)').text(title + ': ' + categories.join(', '));
			} else if (categories.length > 3) {
				$('#' + field + '_hier_link').attr('title', title + ': ' + categories.length + ' selected');
				$('#' + field + '_hier_link').children('span:nth-child(2)').text(title + ': ' + categories.length + ' selected');
			}
		}
	});
}