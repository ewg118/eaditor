/* Author: Ethan Gruber
    Date: September 2020
    Function: instantiate a Mirador 3.x viewer for IIIF manifests */
$(document).ready(function () {
    //get necessary variables
    var publisher = encodeURI($('#publisher').text());
    var manifestURI = $('#manifestURI').text();
    var hasAnnotations = ($('#hasAnnotations').text().toLowerCase() == 'true');
    
    //construct Mirador window objects dynamically
    var windowObjects =[];
    var windowOptions = {
    };
    
    if (window.location.hash) {
        var id = window.location.hash.substring(1);
        var canvasID = manifestURI + '/canvas/' + id;
        windowOptions[ "canvasId"] = canvasID;
    }
    
    windowOptions[ "loadedManifest"] = manifestURI;
    windowOptions[ "id"] = "default";
    windowOptions[ "thumbnailNavigationPosition"] = "far-bottom";
    windowObjects.push(windowOptions);
    
    var miradorInstance = Mirador.viewer({
        "id": "mirador-div",
        "manifests": {
            manifestURI: {
                "provider": publisher
            }
        },
        "windows": windowObjects,
        "window": {
            "allowClose": false,
            "allowMaximize": false,
            "defaultSideBarPanel": ((hasAnnotations == true) ? 'annotations' : 'info'),
            "defaultView": 'gallery',
            "sideBarOpenByDefault": hasAnnotations,
            "forceDrawAnnotations": true
        },
        "thumbnailNavigation": {
            "defaultPosition": 'off'
        },
        "workspace": {
            "type": 'mosaic'
        },
        "workspaceControlPanel": {
            "enabled": false
        },
        "theme": {
            "palette": {
                "annotations": {
                    "hidden": {
                        "globalAlpha": 1
                    }
                }
            }
        }
    });
    
    //pagination for index
    $('.page-image').click(function () {
        var canvasID = $(this).attr('canvas');
        var action = Mirador.actions.setCanvas('default', canvasID);
        miradorInstance.store.dispatch(action);
    });
});