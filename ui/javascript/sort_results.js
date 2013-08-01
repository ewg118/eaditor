/************************************
SORT SEARCH RESULTS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Used to generate the query for adding
the sort parameter to solr.
************************************/
$(document).ready(function(){
	$('.sortForm_categories') .change(function(){
		var val = $(this).val();
		var sort_order = $('.sortForm_order').val();		
		if (val.length > 0) {
			sort_value = get_sort_value(val, sort_order);
			$('.sort_param') .attr('value', sort_value);
			$('#sort_button') .removeAttr('disabled');
		} else {
			$('#sort_button') .attr('disabled', 'disabled');
		}
	});
	
	$('.sortForm_order') .change(function(){
		var sort_order = $(this).val();
		var val = $('.sortForm_categories').val();
		if (val.length > 0) {
			sort_value = get_sort_value(val, sort_order);
			$('.sort_param') .attr('value', sort_value);
			$('#sort_button') .removeAttr('disabled');
		} else {
			$('#sort_button') .attr('disabled', 'disabled');
		}
	});
	
	$('#sort_button').click(function(){
		var q = $(this).siblings('input[name=q]').val();
		var sort = $(this).siblings('input[name=sort]').val();
		
		//apply lang if available
		if ($(this).siblings('input[name=lang]').length > 0){
			var lang = $(this).siblings('input[name=sort]').val();			
			window.location = './?q=' + q + '&sort=' + sort + '&lang=' + lang;
		} else {
			window.location = './?q=' + q + '&sort=' + sort
		}
		return false;
	});
	
	function get_sort_value (val, sort_order){
		if (val == 'year_num' || val == 'timestamp' || val == 'unittitle_display'){
			var category = val;
		} else {
			switch(sort_order){
			case 'asc':
				var category = val + '_min';
				break;
			case 'desc':
				var category = val + '_max';
			}
		}
		return category + ' ' + sort_order;
	}
});