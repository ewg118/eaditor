/************************************
SEARCH
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Portions of this originally authored by Matt Mitchell.
Modified heavily to handle the search form functionality
and piecing together the search query.
************************************/
$(document).ready(function() {

	/***** TOGGLING FACET FORM*****/
	$('.inputContainer') .on('click', '.searchItemTemplate .gateTypeBtn', function () {
		gateTypeBtnClick($(this));
		//disable date select option if there is already a date select option
		if ($(this).closest('form').attr('id') == 'sparqlForm') {
			var count = countDate();
			if (count == 1) {
				$('#sparqlForm .searchItemTemplate').each(function () {
					//disable all new searchItemTemplates which are not already set to date
					if ($(this).children('.sparql_facets').val() != 'date') {
						$(this).find('option[value=date]').attr('disabled', true);
					}
				});
			}
		}
		
		return false;
	});
	$('.inputContainer').on('click', '.searchItemTemplate .removeBtn', function () {
		//enable date option in sparql form if the date is being removed
		if ($(this).closest('form').attr('id') == 'sparqlForm') {
			$('#sparqlForm .searchItemTemplate').each(function () {
				$(this).find('option[value=date]').attr('disabled', false);
				//enable submit
				$('#sparqlForm input[type=submit]').attr('disabled', false);
				//hide error
				$('#sparqlForm-alert').hide();
			});
		}
		
		// fade out the entire template
		$(this) .parent() .fadeOut('fast', function () {
			$(this) .remove();
		});
		return false;
	});
	
	$('.inputContainer').on('change', '.searchItemTemplate .category_list', function () {
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
	
	// activates the advanced search action
	$('#advancedSearchForm').submit(function() {
		var query = new Array();
		
		// loop through each ".searchItemTemplate" and build the query
		$('.inputContainer .searchItemTemplate') .each(function () {
			var field = $(this) .children('.category_list') .val();
			if ($(this).children('.option_container').html().indexOf('search_text') > 0 && $(this) .children('.option_container') .children('.search_text') .val().length > 0) {
				query.push (field + ':' + $(this) .children('.option_container') .children('.search_text') .val());
			} 
		});
		// pass the query to the search_results url passing the needed url params:
		if (query.length == 0){
			$('#q_input') .attr('value', '*:*');
		} else {
			$('#q_input') .attr('value', query.join(' AND '));
		}
		
	});
});

// copy the base template
function gateTypeBtnClick(btn) {
	var formId = btn.closest('form').attr('id');
	
	//clone the template
	var tpl = cloneTemplate(formId);
	
	// focus the text field after select
	$(tpl) .children('select') .change(function () {
		$(this) .siblings('input') .focus();
	});
	
	// add the new template to the dom
	$(btn) .parent() .after(tpl);
	
	tpl.children('.removeBtn').removeAttr('style');
	tpl.children('.removeBtn') .before(' |&nbsp;');
	
	// display the entire new template
	tpl.fadeIn('fast');
}

function cloneTemplate(formId) {
	if (formId == 'sparqlForm') {
		var tpl = $('#sparqlItemTemplate') .clone();
	} else {
		var tpl = $('#searchItemTemplate') .clone();
	}
	
	//remove id to avoid duplication with the template
	tpl.removeAttr('id');
	
	return tpl;
}
	
