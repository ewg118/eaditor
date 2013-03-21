/************************************
GET TABLE OF CONTENTS IN EAD GUIDE LIST (ADMIN HOME)
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This calls the navigation/* pipeline to show/hide the table of contents for a finding aid
in the admin home file liest
************************************/
$(function () {
	$('.expand') .click(function () {
		var id = $(this) .attr('id').split('-')[0];
		var container = id + '_container';
		if ($(this) .text() == 'expand') {					
			$(this) .text('collapse');
			if ($('.' + container).html().indexOf('<li>') < 0){		
				$.get('navigation/' + id, { },
					function (data) {				
						$('#temp') .html(data);
						$('#temp ul.list').clone().appendTo('.' + container);
						$('.' + container) .fadeIn('slow');	
					}
					
				);
			}else {
				$('.' + container) .fadeIn('slow');
			}
			return false;
		} else if ($(this) .text() == 'collapse') {
			$('.' + container) .fadeOut('slow');
			$(this) .text('expand');
			return false;
		}
	});
});