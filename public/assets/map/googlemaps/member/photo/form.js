this.Member_Photo_Form=function(){function r(){}return r.maxPointForm=10,r.deleteMessage="\u30de\u30fc\u30ab\u30fc\u3092\u524a\u9664\u3057\u3066\u3088\u308d\u3057\u3044\u3067\u3059\u304b\uff1f",r.setExifMessage="\u753b\u50cf\u306b\u4f4d\u7f6e\u60c5\u5831\u304c\u542b\u307e\u308c\u3066\u3044\u307e\u3059\u3002\u4f4d\u7f6e\u60c5\u5831\u3092\u5730\u56f3\u306b\u8a2d\u5b9a\u3057\u307e\u3059\u304b\uff1f",r.dataID=0,r.clickIcon="//maps.google.com/mapfiles/ms/icons/blue-dot.png",r.clickMarker=null,r.setMapLoc=function(a,e,o){e=Math.ceil(e*Math.pow(10,6))/Math.pow(10,6),o=Math.ceil(o*Math.pow(10,6))/Math.pow(10,6),a.val(e.toFixed(6)+","+o.toFixed(6))},r.getMapLoc=function(a){var e;return e=a.val().split(","),new google.maps.LatLng(parseFloat(e[0]),parseFloat(e[1]))},r.attachMessage=function(t){google.maps.event.addListener(Googlemaps_Map.markers[t],"click",function(){Googlemaps_Map.openedInfo&&Googlemaps_Map.openedInfo.close(),$('dd[data-id = "'+t+'"]').each(function(){var a,e,o;return e=$(this).find(".marker-name").val(),o=$(this).find(".marker-text").val(),""===e&&""===o||(a='<div class="marker-info">',""!==e&&(a+="<p>"+e+"</p>"),""!==o&&$.each(o.split(/[\r\n]+/),function(){return this.match(/^https?:\/\//)?a+='<p><a href="'+this+'">'+this+"</a></p>":a+="<p>"+this+"</p>"}),Googlemaps_Map.openedInfo=new google.maps.InfoWindow({content:a,maxWidth:260}),Googlemaps_Map.openedInfo.open(Googlemaps_Map.markers[t].getMap(),Googlemaps_Map.markers[t])),!1})})},r.clearMarker=function(a){var e;e=0,""!==a.val()?confirm(r.deleteMessage)&&Googlemaps_Map.markers[e]&&(Googlemaps_Map.markers[e].setMap(null),a.val("")):Googlemaps_Map.markers[e]&&Googlemaps_Map.markers[e].setMap(null)},r.createMarker=function(a){var e;""!==$(".mod-map .clicked").val()&&(a.val($(".mod-map .clicked").val()),e=0,Googlemaps_Map.markers[e]&&Googlemaps_Map.markers[e].setMap(null),Googlemaps_Map.markers[e]=new google.maps.Marker({position:r.getMapLoc($(".mod-map .marker-loc")),map:Googlemaps_Map.map}),r.attachMessage(e))},r.renderMarkers=function(){var a,e,o,t;if(o=new google.maps.LatLngBounds,Googlemaps_Map.markers)for(a=0,e=(t=Googlemaps_Map.markers).length;a<e;a++)t[a].setMap(null);Googlemaps_Map.markers=[],r.dataID=0,$(".mod-map .marker").each(function(){var a;return $(this).attr("data-id",r.dataID),""!==$(this).find(".marker-loc").val()&&(a=r.getMapLoc($(this).find(".marker-loc")),Googlemaps_Map.markers[r.dataID]=new google.maps.Marker({position:a,map:Googlemaps_Map.map}),r.attachMessage(r.dataID),o.extend(a)),r.dataID+=1}),Googlemaps_Map.adjustMarkerBounds(Googlemaps_Map.markers.length,o)},r.setExifLatLng=function(a){return $(a).on("change",function(a){if(a.target.files[0])return EXIF.getData(a.target.files[0],function(){var a,e,o,t;return a=EXIF.getTag(this,"GPSLatitude"),o=EXIF.getTag(this,"GPSLongitude"),e=EXIF.getTag(this,"GPSLatitudeRef")||"N",t=EXIF.getTag(this,"GPSLongitudeRef")||"W",!(!a||!o)&&(!!confirm(r.setExifMessage)&&(e="N"===e?1:-1,t="W"===t?-1:1,a=(a[0]+a[1]/60+a[2]/3600)*e,o=(o[0]+o[1]/60+o[2]/3600)*t,$(".mod-map .clicked").val([a,o].join()),r.createMarker($(".mod-map .marker-loc")),Googlemaps_Map.map.setCenter(new google.maps.LatLng(a,o))))})})},r.renderEvents=function(){google.maps.event.addListener(Googlemaps_Map.map,"click",function(a){return r.setMapLoc($(".mod-map .clicked"),a.latLng.lat(),a.latLng.lng()),r.createMarker($(".mod-map .marker-loc"))}),$(".mod-map .clear-marker").on("click",function(){return r.clearMarker($(".mod-map .marker-loc")),!1}),$(".mod-map .set-center-position").on("click",function(){var a=Googlemaps_Map.map.getCenter(),e=Math.floor(1e6*a.lat())/1e6,o=Math.floor(1e6*a.lng())/1e6;return $(".center-input").val(e+","+o),!1}),$(".mod-map .set-zoom-level").on("click",function(){return $(".zoom-input").val(Googlemaps_Map.map.getZoom()),!1}),google.maps.event.addListener(Googlemaps_Map.map,"bounds_changed",function(){var a=Googlemaps_Map.map.getZoom();$('input[name="item[map_zoom_level]"]').val(a)})},r}();