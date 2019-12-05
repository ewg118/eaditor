/********
* Author: Ethan Gruber
* Last modified: January 2019
* Function: Parse URIs pasted into WebAnnotorious annotations to extract human readable labels and construct HTML links
*********/

/********** URI PARSING **********/
//construct HTML links from regular expressions
function replaceURLWithHTMLLinks(text) {
    var exp = /((^|\s)?https?:\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])($|\s)/ig;
    return text.replace(exp, constructLink);
}

function constructLink(match, p1, offset, string) {
    var spacer = (p1.substring(0, 1) == ' ' ? ' ' : '')
    p1 = p1.trim();
    
    //perform API call to normalize the inserted link into the stable entity URI and preferred label
    entity = getLabel(p1);  
    
    return spacer + "<a href='" + entity.uri.replace('&', '&amp;') + "'>" + entity.label.replace('&', '&amp;') + "</a>";
}

//construct the linkable text depending on the URI (handle nomisma and Mantis URIs)
function getLabel(uri) {
    var label;
    var path = '../../../' + ORBEON.xforms.Document.getValue('collection-name') + '/';
    $.ajaxSetup({
        async: false
    });
    $.getJSON(path + 'get_label', {
        uri: uri
    },
    function (data) {
        label = data;
    });
    return label;
}