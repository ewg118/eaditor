$(document).ready(function () {
    //get necessary variables
    var publisher = encodeURI($('#publisher').text());
    var miradorURI = $('#miradorURI').text();
    var manifestURI = $('#manifestURI').text();
    
    if (window.location.hash) {
        var id = window.location.hash.substring(1);
        var canvasID = manifestURI + '/canvas/' + id;
    } else {
        var canvasID = '';
    }
    
    myMiradorInstance = initialize(miradorURI, manifestURI, canvasID, publisher);
    
    //pagination for index
    $('.page-image').click(function () {
        if (myMiradorInstance.saveController.slots[0].window.id) {
            var windowID = myMiradorInstance.saveController.slots[0].window.id;
            var canvasID = $(this).attr('canvas');
            myMiradorInstance.eventEmitter.publish('SET_CURRENT_CANVAS_ID.' + windowID, canvasID);
        }
        return false;
    });
});

function initialize (miradorURI, manifestURI, canvasID, publisher) {
    var windowObjects =[];
    var windowOptions = {
    };
    
    
    if (canvasID) {
        windowOptions[ "canvasID"] = canvasID;
    }
    windowOptions[ "loadedManifest"] = manifestURI;
    windowOptions[ "viewType"] = "ImageView";
/*    windowOptions[ "annotationLayer"] = true;
    windowOptions[ "annotationCreation"] = false;
    windowOptions[ "annotationState"] = "on";*/
    windowOptions[ "displayLayout"] = false;
    
    
    windowObjects.push(windowOptions);
    
    return Mirador({
        "id": "mirador-div",
        "buildPath": miradorURI + 'build/mirador/',
        "layout": "1x1",
        "mainMenuSettings.show": false,
        "data":[ {
            "manifestUri": manifestURI, "location": publisher
        }],
        "canvasControls": {
            "annotations": {
                "annotationLayer": true,
                "annotationCreation": false,
                "annotationState": "on"
            }
        },
        "windowObjects": windowObjects,
        "sidePanelVisible": false
    });
}