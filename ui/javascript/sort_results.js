/************************************
SORT SEARCH RESULTS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Used to generate the query for adding
the sort parameter to solr.
************************************/
$(function () {
	$('.sortForm_categories') .change(function(){
		var category = $(this) .attr('value');
		var sort_order = $('.sortForm_order') .attr('value');
		if (category != 'null'){
			$('#sort_button') .removeAttr('disabled');
			$('.sort_param') .attr('value', category + ' ' + sort_order);
		}
		else {
			$('#sort_button') .attr('disabled', 'disabled');
		}
	});
	$('.sortForm_order') .change(function(){
		var sort_order = $(this) .attr('value');
		var category = $('.sortForm_categories') .attr('value');
		if (category != 'null'){
			$('#sort_button') .removeAttr('disabled');
			$('.sort_param') .attr('value', category + ' ' + sort_order);

		}
		else {
			$('#sort_button') .attr('disabled', 'disabled');
		}
	});
});