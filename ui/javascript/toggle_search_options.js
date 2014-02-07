/************************************
TOGGLE SEARCH OPTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This javascript file handles the dynamic search form
in the search and search results pages.  Some fields require
text boxes, some require the entry of integers to search a range,
and the remaining query solr and return unique facets and write
them to the drop-down menu.
************************************/

$(document).ready(function() {		
	$('.category_list') .livequery('change', function(event){
		var selected_id = $(this) .children("option:selected") .attr('id');
		var num = $(this) .parent() .attr('id') .split('_')[1];
		var field = $(this).children('option:selected').val();
		if (field == 'text' || field.indexOf('_text') > 0 || field.indexOf('_display') > 0) {
			if ($(this) .parent() .children('.option_container') .children('input') .attr('class') != 'search_text') {
				$(this) .parent() .children('.option_container') .html('');
				$(this) .parent() .children('.option_container') .html('<input type="text" id="search_text" class="search_text"/>');
			}
		}
		//SELECTING OTHER DROP DOWN MENUS SECTION
		else {
			var category = $(this) .children("option:selected") .attr('value');
			$(this) .parent('.searchItemTemplate') .children('.option_container') .html('<select class="search_text"></select>');			
			$.get('../get_facets/', {
				q : category + ':[* TO *]', category:category, sort: 'index', limit:-1
			}, function (data) {
				$('#ajax-temp').html(data);
				if ($('#ajax-temp').html().indexOf('<option') > 0){
					$('#ajax-temp option').each(function(){
						$(this).clone().appendTo($('#container_' + num).children('.search_text'));
					});
					$('#container_' + num).children('.search_text').selectmenu({'style':'dropdown'});
				} else {
					$('#container_' + num).text('None found');
				}
			});				
		}
		
	});
});