$(document).ready(function () {
    //initiate
    var publisher = encodeURI($('#publisher').text());
    var miradorURI = $('#miradorURI').text();
    var manifestURI = $('#manifestURI').text();
    initiateMirador(miradorURI, manifestURI, canvas='', publisher);
    
    
    $('.page-image').click(function () {
        
        var manifestURI = $('#manifestURI').text();
        var canvas = $(this).attr('canvas');
        //var src = miradorURI + '?manifest=' + manifestURI + '&canvas=' + canvas + '&publisher=' + publisher;
        
        //$('#iiif-iframe').attr('src', src);
        
        
        
        return false;
    });
});

function initiateMirador(miradorURI, manifest, canvas, publisher) {

    var windowObjects =[];
    var windowOptions = {
    };
    
    if (manifest) {
        windowOptions[ "loadedManifest"] = manifest;
    }
    if (canvas) {
        windowOptions[ "canvasID"] = canvas;
    }
    
    windowOptions[ "viewType"] = "ImageView";
    windowOptions[ "annotationLayer"] = true;
    windowOptions[ "annotationCreation"] = false;
    windowOptions[ "annotationState"] = "annoOnCreateOff";
    windowOptions[ "displayLayout"] = false;
    
    
    windowObjects.push(windowOptions);
    
    Mirador({
        "id": "mirador-div",
        "buildPath": miradorURI + 'build/mirador/',
        "layout": "1x1",
        "data":[ {
            "manifestUri": manifest, "location": publisher
        }],
        "windowObjects": windowObjects,
        "sidePanelVisible": false
    });
}