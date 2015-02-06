REBOL[
	Title: "Google Maps plugin for LEST"
	Type: 'lest-plugin
	Name: 'google-map
]


main-rule: [
	; google maps

;
; TODO: worked, now does not. Probably needs some requirements.
;
; currently uses iframe method (but that's not dynamic)
	'map
	set location pair!
	(
;			emit rejoin [ ""
;   				<div id="contact" class="map"> newline
;   					<div id="map_canvas"></div> newline
;   				</div> newline
;   				<script>
;   				{google.maps.event.addDomListener(window, 'load', setMapPosition(} location/x #"," location/y {));}
;   				</script>
;    		]
		emit ajoin [
{<iframe width="425" height="350" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=cs&amp;geocode=&amp;sll=} location/x #"," location/y {&amp;sspn=0.035292,0.066175&amp;t=h&amp;ie=UTF8&amp;hq=&amp;z=14&amp;ll=} location/x #"," location/y {&amp;output=embed">}
</iframe><br /><small>
{<a href="https://maps.google.com/maps?f=q&amp;source=embed&amp;hl=cs&amp;geocode=&amp;aq=&amp;sll=} location/x #"," location/y {&amp;sspn=0.035292,0.066175&amp;t=h&amp;ie=UTF8&amp;hq=&amp;hnear=Mez%C3%ADrka,+Brno,+%C4%8Cesk%C3%A1+republika&amp;z=14&amp;ll=} location/x #"," location/y {" style="color:#0000FF;text-align:left">Zvětšit mapu}
</a></small>
		]


	)
]
