/************************************
GET TABLE OF CONTENTS IN EAD GUIDE LIST (ADMIN HOME)
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This calls the navigation/* pipeline to show/hide the table of contents for a finding aid
in the admin home file liest
 ************************************/
function expand() {
	var collection = ORBEON.xforms.Document.getValue('collection-name');
	var id = ORBEON.xforms.Document.getValue('eadid');

	var container = id + '_container';
	if ($(this).text() == 'expand') {
		$(this).text('collapse');
		if ($('.' + container).html().indexOf('<li>') < 0) {
			$.get('navigation/?collection=' + collection + '&guide=' + id, {
			},
			function (data) {
				$('#temp').html(data);
				$('#temp ul.list').clone().appendTo('#' + container);
				$('.' + container).fadeIn('slow');
			});
		} else {
			$('#' + container).fadeIn('slow');
		}
		return false;
	} else if ($(this).text() == 'collapse') {
		$('#' + container).fadeOut('slow');
		$(this).text('expand');
		return false;
	}
}

/*$(function () {
alert('test');
$('.expand') .click(function () {
alert('test');

return false;
/\*var collection = $('#collection-name').text();

var id = $(this) .attr('id').split('-')[0];
var container = id + '_container';
if ($(this) .text() == 'expand') {
$(this) .text('collapse');
if ($('.' + container).html().indexOf('<li>') < 0){
$.get('navigation/?collection=' + collection + '&guide=' + id, { },
function (data) {
$('#temp') .html(data);
$('#temp ul.list').clone().appendTo('#' + container);
$('.' + container) .fadeIn('slow');
}

);
}else {
$('#' + container) .fadeIn('slow');
}
return false;
} else if ($(this) .text() == 'collapse') {
$('#' + container) .fadeOut('slow');
$(this) .text('expand');
return false;
}*\/
});
});*/