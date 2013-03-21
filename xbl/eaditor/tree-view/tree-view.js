/************************************
TREE VIEW
Written by Ethan Gruber, ewg4xuva -at- gmail.com
Library: jQuery
Description: Expand and collapse the tree-view listing of EAD components
************************************/

$(document).ready(function() {
	$('.nodename') .click(function(){
		if ($(this) .parent('ul') .attr('class') == 'collapsed'){
			$(this) .parent('ul') .attr('class', 'expanded');
			$(this) .children('.xforms-group') .children('.xforms-trigger').children('.trigger-image') .attr('src', $(this) .children('.xforms-group') .children('.xforms-trigger').children('.trigger-image') .attr('src') .replace('plus', 'minus'));
		} else {
			$(this) .parent('ul') .attr('class', 'collapsed');
			$(this) .children('.xforms-group') .children('.xforms-trigger').children('.trigger-image') .attr('src', $(this) .children('.xforms-group') .children('.xforms-trigger').children('.trigger-image') .attr('src') .replace('minus', 'plus'));
		}
	});
});