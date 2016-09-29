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
	
	if (ORBEON.jQuery('.' + container).html().indexOf('<li>') < 0) {
		ORBEON.jQuery.get('navigation/?collection=' + collection + '&guide=' + id, {
		},
		function (data) {
			ORBEON.jQuery('.' + container).html(data);
			ORBEON.jQuery('.' + container).removeClass('hidden');
		});
	} else {
		if (ORBEON.jQuery('.' + container).hasClass('hidden')){
			ORBEON.jQuery('.' + container).removeClass('hidden');
		} else {
			ORBEON.jQuery('.' + container).addClass('hidden');
		}
	}
}