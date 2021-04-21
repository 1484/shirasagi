this.Map_Form=function(){function n(){}return n.maxPointForm=10,n.deleteMessage="\u30de\u30fc\u30ab\u30fc\u3092\u524a\u9664\u3057\u3066\u3088\u308d\u3057\u3044\u3067\u3059\u304b\uff1f",n.dataID=0,n.clickIcon="//maps.google.com/mapfiles/ms/icons/blue-dot.png",n.clickMarker=null,n.setMapLoc=function(a,e,r){e=Math.ceil(e*Math.pow(10,6))/Math.pow(10,6),r=Math.ceil(r*Math.pow(10,6))/Math.pow(10,6),a.val(e.toFixed(6)+","+r.toFixed(6))},n.getMapLoc=function(a){var e;return e=a.val().split(","),new google.maps.LatLng(parseFloat(e[0]),parseFloat(e[1]))},n.validateLoc=function(a){var e,r,o;return r=a.val().split(","),e=parseFloat(r[0]),o=parseFloat(r[1]),!(!e||isNaN(e))&&(!(!o||isNaN(o))&&(-90<=e&&e<=90&&-180<=o&&o<=180))},n.attachMessage=function(o){google.maps.event.addListener(Googlemaps_Map.markers[o],"click",function(){Googlemaps_Map.openedInfo&&Googlemaps_Map.openedInfo.close(),$('dd[data-id = "'+o+'"]').each(function(){var a,e,r;return e=$(this).find(".marker-name").val(),r=$(this).find(".marker-text").val(),""===e&&""===r||(a='<div class="marker-info">',""!==e&&(a+="<p>"+e+"</p>"),""!==r&&$.each(r.split(/[\r\n]+/),function(){return this.match(/^https?:\/\//)?a+='<p><a href="'+this+'">'+this+"</a></p>":a+="<p>"+this+"</p>"}),Googlemaps_Map.openedInfo=new google.maps.InfoWindow({content:a,maxWidth:260}),Googlemaps_Map.openedInfo.open(Googlemaps_Map.markers[o].getMap(),Googlemaps_Map.markers[o])),!1})})},n.geocoderSearch=function(a){return(new google.maps.Geocoder).geocode({address:a,region:"jp"},function(a,e){var r;e===google.maps.GeocoderStatus.OK?(r=a[0],Googlemaps_Map.map.setCenter(r.geometry.location),r.geometry.viewport&&Googlemaps_Map.map.fitBounds(r.geometry.viewport)):alert("\u5ea7\u6a19\u3092\u53d6\u5f97\u3067\u304d\u307e\u305b\u3093\u3067\u3057\u305f\u3002")}),!1},n.clonePointForm=function(){var a;$(".mod-map dd.marker").length<n.maxPointForm&&((a=$(".mod-map dd.marker:last").clone(!1).insertAfter($(".mod-map dd.marker:last"))).attr("data-id",n.dataID),n.dataID+=1,a.find("input,textarea").val(""),a.find(".marker-name").val(""),a.find(".clear-marker").on("click",function(){return n.clearPointForm(a)}),a.find(".set-marker").on("click",function(){return n.createMarker(a)}),a.find(".marker-name").on("keypress",function(a){if(13===a.which)return!1}),a.find(".marker-loc-input").on("keypress",function(a){if(13===a.which)return $(this).closest("dd.marker").find(".set-marker").trigger("click"),!1}),a.find(".marker-loc-input").on("focus",function(){if(null!==n.clickMarker)return n.clickMarker.setMap(null),$(".mod-map .clicked").val("")})),$(".mod-map dd.marker").length===n.maxPointForm&&$(".mod-map dd .add-marker").parent().hide()},n.clearPointForm=function(a){""!==a.find(".marker-loc").val()?confirm(n.deleteMessage)&&(Googlemaps_Map.markers[parseInt(a.attr("data-id"))]&&Googlemaps_Map.markers[parseInt(a.attr("data-id"))].setMap(null),a.find("input,textarea").val(""),1<$(".mod-map dd.marker").length&&a.remove()):(Googlemaps_Map.markers[parseInt(a.attr("data-id"))]&&Googlemaps_Map.markers[parseInt(a.attr("data-id"))].setMap(null),a.find("input,textarea").val(""),1<$(".mod-map dd.marker").length&&a.remove()),$(".mod-map dd .add-marker").parent().show()},n.clonePointFormNoApi=function(){var a;$(".mod-map dd.marker").length<n.maxPointForm&&((a=$(".mod-map dd.marker:last").clone(!1).insertAfter($(".mod-map dd.marker:last"))).attr("data-id",n.dataID),n.dataID+=1,a.find("input,textarea").val(""),a.find(".marker-name").val(""),a.find(".clear-marker").on("click",function(){return n.clearPointFormNoApi(a)}),a.find(".marker-name").on("keypress",function(a){if(13===a.which)return!1}),a.find(".marker-loc-input").on("keypress",function(a){if(13===a.which)return!1})),$(".mod-map dd.marker").length===n.maxPointForm&&$(".mod-map dd .add-marker").parent().hide()},n.clearPointFormNoApi=function(a){""!==a.find(".marker-loc-input").val()?confirm(n.deleteMessage)&&(a.find("input,textarea").val(""),1<$(".mod-map dd.marker").length&&a.remove()):(a.find("input,textarea").val(""),1<$(".mod-map dd.marker").length&&a.remove()),$(".mod-map dd .add-marker").parent().show()},n.createMarker=function(a){var e,r;if(r=null,""!==$(".mod-map .clicked").val()?r=$(".mod-map .clicked").val():""!==a.find(".marker-loc-input").val()&&(n.validateLoc(a.find(".marker-loc-input"))?r=a.find(".marker-loc-input").val():alert("\u6b63\u3057\u3044\u5ea7\u6a19\u3092\u30ab\u30f3\u30de(,)\u533a\u5207\u308a\u3067\u5165\u529b\u3057\u3066\u304f\u3060\u3055\u3044\u3002\n\u4f8b\uff0933.8957612,133.6806607")),r)return a.find(".marker-loc").val(r),a.find(".marker-loc-input").val(r),e=parseInt(a.attr("data-id")),Googlemaps_Map.markers[e]&&Googlemaps_Map.markers[e].setMap(null),Googlemaps_Map.markers[e]=new google.maps.Marker({position:n.getMapLoc(a.find(".marker-loc")),map:Googlemaps_Map.map}),n.attachMessage(e),n.clickMarker?($(".mod-map .clicked").val(""),n.clickMarker.setMap(null)):void 0},n.renderMarkers=function(){var a,e,r;if(r=new google.maps.LatLngBounds,Googlemaps_Map.markers){var o=Googlemaps_Map.markers;for(a=0,e=o.length;a<e;a++){o[a].setMap(null)}}Googlemaps_Map.markers=[],n.dataID=0,$(".mod-map dd.marker").each(function(){if($(this).attr("data-id",n.dataID),""!==$(this).find(".marker-loc").val()){var a=n.getMapLoc($(this).find(".marker-loc"));Googlemaps_Map.markers[n.dataID]=new google.maps.Marker({position:a,map:Googlemaps_Map.map}),n.attachMessage(n.dataID),r.extend(a)}n.dataID+=1}),Googlemaps_Map.adjustMarkerBounds(Googlemaps_Map.markers.length,r)},n.renderEvents=function(){return google.maps.event.addListener(Googlemaps_Map.map,"click",function(a){return n.setMapLoc($(".mod-map .clicked"),a.latLng.lat(),a.latLng.lng()),null!==n.clickMarker&&n.clickMarker.setMap(null),n.clickMarker=new google.maps.Marker({position:new google.maps.LatLng(a.latLng.lat(),a.latLng.lng()),icon:n.clickIcon,map:Googlemaps_Map.map})}),google.maps.event.addListener(Googlemaps_Map.map,"bounds_changed",function(){var a=Googlemaps_Map.map.getZoom();$('input[name="item[map_zoom_level]"]').val(a)}),$(".mod-map .add-marker").on("click",function(){return n.clonePointForm(),!1}),$(".mod-map .clear-marker").on("click",function(){return n.clearPointForm($(this).closest("dd.marker")),!1}),$(".mod-map .set-center-position").on("click",function(){var a=Googlemaps_Map.map.getCenter(),e=Math.floor(1e6*a.lat())/1e6,r=Math.floor(1e6*a.lng())/1e6;return $(".center-input").val(e+","+r),!1}),$(".mod-map .set-zoom-level").on("click",function(){return $(".zoom-input").val(Googlemaps_Map.map.getZoom()),!1}),$(".mod-map .set-marker").on("click",function(){return n.createMarker($(this).closest("dd.marker")),!1}),$(".mod-map .location-search button").on("click",function(){return n.geocoderSearch($(".mod-map .keyword").val()),!1}),$(".mod-map .keyword").on("keypress",function(a){if(13===a.which)return n.geocoderSearch($(this).val()),!1}),$(".mod-map .marker-name").on("keypress",function(a){if(13===a.which)return!1}),$(".mod-map .marker-loc-input").on("keypress",function(a){if(13===a.which)return $(this).closest("dd.marker").find(".set-marker").trigger("click"),!1}),$(".mod-map .marker-loc-input").on("focus",function(){if(null!==n.clickMarker)return n.clickMarker.setMap(null),$(".mod-map .clicked").val("")})},n}();