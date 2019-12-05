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
    //parse URI to normalize it
    if (p1.indexOf('viaf.org') > 0) {
        var pieces = p1.split('/');
        var normalized = 'http://viaf.org/viaf/' + pieces[4];
    } else if (p1.indexOf('geonames.org') > 0) {
        var pieces = p1.split('/');
        var normalized = 'http://www.geonames.org/' + pieces[3];
    } else if (p1.indexOf('wikipedia.org') > 0) {
        var pieces = p1.split('/');
        var normalized = 'http://dbpedia.org/resource/' + pieces[pieces.length - 1];
    } else {
        var normalized = p1;
    }
    
    return spacer + "<a href='" + normalized + "'>" + getLabel(p1) + "</a>";
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
        label = data.label.replace('&', '&amp;');
    });
    return label;
}