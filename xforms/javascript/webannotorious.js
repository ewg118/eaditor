/// webannotorious.js by KANZAKI, Masahide. ver 1.18, 2018-05-01. MIT license.
(function ($) {
    $.Viewer.prototype.annotator = function (osdv, options, myanno) {
        if (! this.antctrl || options) {
            options = options || {
            };
            options.viewer = this;
            options.touchdev = osdv.touchdev;
            this.antctrl = new $.AntriusCtrl(options, osdv.elt, myanno);
        }
    };
    $.AntriusCtrl = function (options, osdvelt, myanno) {
        $.extend(true, this, {
            prefixUrl: null,
            navImages: {
                annotator: {
                    REST: 'selection_rest.png',
                    GROUP: 'selection_grouphover.png',
                    HOVER: 'selection_hover.png',
                    DOWN: 'selection_pressed.png'
                }
            }
        },
        options);
        var handler = options.h ? function () {
            options.h(options.hparam);
            myanno.activateSelector();
        }: function () {
            myanno.activateSelector();
        };
        
        var prefix = this.prefixUrl || this.viewer.prefixUrl || '';
        var useGroup = this.viewer.buttons && this.viewer.buttons.buttons;
        var anyButton = useGroup ? this.viewer.buttons.buttons[0]: null;
        var onFocusHandler = anyButton ? anyButton.onFocus: null;
        var onBlurHandler = anyButton ? anyButton.onBlur: null;
        this.toggleButton = new $.Button({
            element: null,
            clickTimeThreshold: this.viewer.clickTimeThreshold,
            clickDistThreshold: this.viewer.clickDistThreshold,
            tooltip: 'Annotator',
            srcRest: prefix + this.navImages.annotator.REST,
            srcGroup: prefix + this.navImages.annotator.GROUP,
            srcHover: prefix + this.navImages.annotator.HOVER,
            srcDown: prefix + this.navImages.annotator.DOWN,
            onRelease: handler,
            onFocus: onFocusHandler,
            onBlur: onBlurHandler
        });
        if (useGroup) {
            this.viewer.buttons.buttons.push(this.toggleButton);
            this.viewer.buttons.element.appendChild(this.toggleButton.element);
        }
        if (options.touchdev) myanno.addHandler("onAnnotationCreated", function (annot) {
            options.viewer.antctrl.add_touch_listener_to_last(annot);
        });
        this.osdvelt = osdvelt;
        this.myanno = myanno;
    };
    $.AntriusCtrl.prototype.add_touch_listener_to_last = function (annot) {
        var boxes = this.get_annoboxes(),
        box = boxes[boxes.length -1];
        this.add_touch_listener(box, annot);
    };
    $.AntriusCtrl.prototype.add_touch_listener = function (box, annot) {
        var that = this;
        box.addEventListener('touchstart', function (e) {
            if (this.getAttribute("data-hilite")) {
                that.myanno.highlightAnnotation(undefined);
                this.setAttribute("data-hilite", "");
            } else {
                that.myanno.highlightAnnotation(annot);
                this.setAttribute("data-hilite", true);
            }
        });
    };
    $.AntriusCtrl.prototype.get_annoboxes = function () {
        return this.osdvelt.getElementsByClassName("annotorious-ol-boxmarker-outer");
    };
    $.AntriusCtrl.prototype.setup_touch_listener = function (annoset) {
        var box = this.get_annoboxes();
        for (var i = 0, n = box.length; i < n; i++) {
            this.add_touch_listener(box[i], annoset[i]);
        }
    };
    $.AntriusCtrl.prototype.cancel_anno_selector = function () {
        this.toggler(true);
    };
    $.AntriusCtrl.prototype.toggler = function (deactivate) {
        var ai = this.osdvelt.getElementsByClassName("annotorious-item");
        if (deactivate || ! ai[0].style.display) {
            ai[0].style.display = "none";
        } else {
            this.myanno.activateSelector();
        }
    };
})(OpenSeadragon);



var at, Miiif;
var WebAnnotorious = function (osdv, option) {
    this.mainviewer = null;
    this.metaprop =[ "created", "modified", "hasNext", "hasPrev"];
    if (osdv) this.setup(osdv, option);
};
WebAnnotorious.prototype = {
    setup: function (osdv, option) {
        this.mainviewer = osdv.viewer;
        if (! this.antrs) this.antrs = new Y();
        this.antrs.makeAnnotatable(osdv.viewer);
        if (! option.nobutton) osdv.viewer.annotator(osdv, option, this.antrs);
    },
    getanno: function (as_ratio, ajson, baseuri, dim, rtype, as_page) {
        var aj = ajson || anno.getAnnotations();
        if (! dim) dim = this.mainviewer.source.dimensions;
        var canvasurl = this.mainviewer.source ? this.mainviewer.source.url: null;
        var frag, item =[];
        for (var i = 0, n = aj.length; i < n; i++) {
            item[i] = this.get_oneanno(as_ratio, aj[i], baseuri, dim, rtype, canvasurl);
        }
        var annocollection = {
            "@context": at.basecontext
        };
        if (as_page) {
            annocollection.type = "AnnotationPage";
            annocollection.items = item;
        } else {
            annocollection[ "@graph"] = item;
        }
        return annocollection;
    },
    get_oneanno: function (as_ratio, aj, baseuri, dimensions, rtype, canvasurl) {
        var text,
        frag = aj.fragid,
        dim = aj.dim || dimensions;
        if (! aj.shapes && aj.target) {
            frag = aj.target.selector.value;
            text = aj.bodyValue;
        } else {
            if (! frag || (as_ratio && frag.match(/xywh=\d/)) || (! as_ratio && frag.match(/xywh=percent/) && dim)) frag = this.getfrag(aj, dim, as_ratio);
            text = at.settext(aj);
        }
        var imgurl = aj.imgurl || canvasurl;
        if (baseuri) imgurl = baseuri + imgurl;
        var item = {
            "type": "Annotation",
            "id": aj.id || this.genid(aj.id, imgurl, frag),
            "bodyValue": text,
            "target": {
                "id": imgurl + "#" + frag,
                "source": imgurl,
                "selector": {
                    "type": "FragmentSelector",
                    "conformsTo": "http://www.w3.org/TR/media-frags/",
                    "value": frag
                }
            }
        };
        if (rtype) item.target.type = rtype;
        var creator = at.setCreator(aj.creator);
        if (creator) item.creator = creator;
        for (var p in this.metaprop) {
            if (aj.hasOwnProperty(this.metaprop[p])) item[ this.metaprop[p]] = aj[ this.metaprop[p]];
        }
        return item;
    },
    getfrag: function (aj, dim, as_ratio) {
        var m = aj.fragid ? aj.fragid.match(/(t=[\d\.,]+)/): null,
        tfrag = m ? "&" + m[1]: "",
        frag;
        if (aj.pix) {
            frag = "xywh=" + aj.pix.join(",");
        } else if (as_ratio) {
            frag = "xywh=" + this.ratio2frag(aj);
        } else {
            var va = this.ratio2px(aj, dim);
            frag = "xywh=" + va.join(",");
        }
        return frag + tfrag;
    },
    genid: function (id, imgurl, frag) {
        //Modified by E.G., use the existing ID when provided by the TEI document/manifest
        if (id){
            //remove default blank node prefix
            return id.replace("_:", "");
        } else {
            return "an_" + at.md5(imgurl + "#" + frag);
            //return at.anbase.pfx + ":" + at.md5(imgurl + "#" + frag);
        }
    },
    ratio2frag: function (an) {
        var g = an.shapes[0].geometry;
        return "percent:" + //viewer.viewport.contentAspectY+"#"+
        Math.round(g.x * 10000) / 100 + "," +
        Math.round(g.y * this.mainviewer.viewport._contentAspectRatio * 10000) / 100 + "," +
        Math.round(g.width * 10000) / 100 + "," +
        Math.round(g.height * this.mainviewer.viewport._contentAspectRatio * 10000) / 100;
    },
    ratio2px: function (an, dim, usefixed, x_adjust) {
        var x = usefixed ? dim.x: ((an.dim && an.dim.x) ? an.dim.x: dim.x);
        var g = an.shapes[0].geometry;
        var x_offset = 0;
        if (x_adjust) {
            if (g.x > x_adjust.offset) {
                x_offset = x_adjust.offset;
                x_adjust.cvidx = 1;
                x = x_adjust.altdim.x;
            }
        }
        return[
        Math.round(x * (g.x - x_offset)),
        Math.round(x * g.y),
        Math.round(x * g.width),
        Math.round(x * g.height)];
    },
    px2ratio: function (frag, dim) {
        if (dim && dim.x_offset && dim.option.use_offset) frag[0] = Number(frag[0]) + dim.x_offset;
        return[
        frag[0] / dim.x,
        frag[1] / dim.x,
        
        frag[2] / dim.x,
        frag[3] / dim.x];
    },
    pct2ratio: function (frag, dim) {
        if (dim && dim.x_offset && dim.option.use_offset) frag[0] = Number(frag[0]) + (dim.x_offset / dim.x) * 100;
        var ar = this.mainviewer.viewport._contentAspectRatio;
        var res =[];
        frag.forEach(function (f) {
            res.push(Number(f) / 100);
        });
        res[1] /= ar;
        res[3] /= ar;
        return res;
    },
    pct2px: function (pct, dim) {
        return[
        Math.round(pct[0] * dim.x / 100),
        Math.round(pct[1] * dim.y / 100),
        Math.round(pct[2] * dim.x / 100),
        Math.round(pct[3] * dim.y / 100)];
    },
    
    setanno: function (annojson, src) {
        var dim = this.mainviewer.source.dimensions, idattr = Miiif ? Miiif.a.id: "@id";
        var imgurl = this.mainviewer.source ? (this.mainviewer.source.url || this.mainviewer.source.imgurl || this.mainviewer.source[idattr]): null;
        src = src || "dzi://openseadragon/something";
        
        if (annojson[ "@graph"]) {
            var annoset =[];
            annojson[ "@graph"].forEach(function (g) {
                var annobj = this.to_annotorious(g, src, dim, imgurl);
                anno.addAnnotation(annobj);
                annoset.push(annobj);
            });
            return annoset;
        } else {
            var annobj = this.to_annotorious(annojson, src, dim, imgurl);
            anno.addAnnotation(annobj);
            return annobj;
        }
    },
    to_annotorious: function (an, src, dim, imgurl, fraganno) {
        if (this.comp_source(an.target.source, imgurl) === false) return false;
        var selector = an.target.selector.value;
        if (an.target.selector.type === "SvgSelector") selector = this.calc_svg_rect(selector);
        var areafrag = an.afrag || selector;
        if (! areafrag || areafrag.substr(0, 4) !== "xywh") return false;
        var frag = this.selector2frag(areafrag, dim);
        var scheme = frag.length === 5 ? frag.pop(): null;
        var annobj = {
            "src": src,
            "text": at.gettext(an),
            "shapes":[ {
                "type": "rect"
            }],
            "id": an.id || this.genid(an.id, imgurl, selector),
            "fragid": selector,
            "creator": at.getCreator(an)
        };
        if (fraganno) this.savefrag(fraganno, annobj, selector);
        for (var p in this.metaprop) {
            if (an.hasOwnProperty(this.metaprop[p])) annobj[ this.metaprop[p]] = an[ this.metaprop[p]];
        }
        if (an.target[ "sc:naturalAngle"]) annobj.rotation = an.target[ "sc:naturalAngle"];
        if (dim) {
            this.setup_geometry(annobj, frag);
            if (! dim.temp) annobj.dimx = dim.x;
            
            //EG: Adding dimy
            if (! dim.temp) annobj.dimy = dim.y;
        } else {
            annobj.pix = frag;
            if (scheme) annobj.scheme = scheme;
        }
        if (imgurl) annobj.imgurl = imgurl;
        return annobj;
    },
    no_scheme: function (uri) {
        return uri.replace(/^https?/, "");
    },
    comp_source: function (u1, u2) {
        if (typeof (u1) !== "string") return "not string";
        if (u1 === u2) return true;
        if (getpath(u1) === getpath(u2)) return true;
        return false;
        
        function getpath(u) {
            var a = document.createElement("a");
            a.setAttribute("href", u);
            return a.pathname;
        }
    },
    savefrag: function (fraganno, annobj, selector) {
        if (fraganno[selector]) {
            fraganno[selector].push(annobj.id);
        } else {
            fraganno[selector] =[annobj.id];
        }
    },
    selector2frag: function (selector, dim) {
        var frag = selector.substr(5).split(',');
        if (frag[0].charAt(0) === "p") {
            var sf = frag[0].split(":");
            scheme = sf[0];
            frag[0] = sf[1];
            if (scheme === "pixel") {
                frag = this.px2ratio(frag, dim);
            } else {
                frag = this.pct2ratio(frag, dim);
                dim = {
                    "temp": true
                };
            }
            frag[4] = scheme;
        } else if (dim) {
            frag = this.px2ratio(frag, dim);
        } else {
            for (var i = 0; i < 4; i++) frag[i] = Number(frag[i]);
        }
        return frag;
    },
    setup_geometry: function (obj, frag) {
        obj.shapes[0].geometry = {
            "x": frag[0],
            "y": frag[1],
            "width": frag[2],
            "height": frag[3]
        };
    },
    check_geometry: function (annos) {
        var dim = this.mainviewer.source.dimensions;
        for (var i = 0, n = annos.length; i < n; i++) {
            frag = annos[i].scheme ? annos[i].pix: this.px2ratio(annos[i].pix, dim);
            this.setup_geometry(annos[i], frag);
            annos[i].pix = null;
        }
    },
    calc_svg_rect: function (selector, dimx) {
        if (! this.svgdiv) {
            this.svgdiv = document.createElement("div");
            this.svgdiv.style.position = "absolute";
            this.svgdiv.style.top = 0;
            this.svgdiv.style.right = 0;
            this.svgdiv.style.zIndex = -100;
            this.svgdiv.style.visibility = "hidden";
            document.body.appendChild(this.svgdiv);
        }
        this.svgdiv.innerHTML = selector;
        var svgelt, cnodes = this.svgdiv.childNodes;
        for (var i = 0, n = cnodes.length; i < n; i++) {
            if (cnodes[i].tagName === "svg") {
                svgelt = cnodes[i];
                break;
            }
        }
        var bbox = svgelt.getBBox(),
        w = svgelt.getAttribute("width");
        if (w && dimx) {
            var adjust = dimx / Number(w);
            for (var key in bbox) bbox[key] *= adjust;
        }
        return "xywh=" +[Math.round(bbox.x), Math.round(bbox.y), Math.round(bbox.width), Math.round(bbox.height)].join(",");
    },
    simpleanno: function (coord, text) {
        return this.setanno({
            "bodyValue": at.link2md(text),
            "target": {
                "selector": {
                    "value": "xywh=" + coord
                }
            }
        });
    }
};