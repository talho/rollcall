
Ext.namespace("Talho.Rollcall.alarm.view");

Talho.Rollcall.alarm.view.GIS = Ext.extend(Ext.Panel, {
  layout: 'fit',
  
  initComponent: function () {
    this.store = new Ext.data.JsonStore({
            
    });
    
    if (this.store.getTotalCount() != 0) {
      this.items = Ext.ux.GMapPanel({zoomLevel: 5});
      
      this.on('afterrender', this._render_gmap_markers);
    }
    Talho.Rollcall.alarm.view.GIS.superclass.initComponent.call(this);
  },
  
  _render_gmap_markers: function (panel) {
    var gmap = panel.get(0);
        
    var set_markers = function () {
      this.store.each(function (record) {
        var color = "red";
        var loc = new google.maps.LatLng(record.get("school_lat"), record.get("school_lng"));
        
        var marker = gmap.addStyledMarker(loc, record.get("school_name"), { color: color });        
        marker.info = this._build_gmap_marker_info(record);
        marker.info_popup = null;
        
        google.maps.event.addListener(marker, 'click', function () {
          if (this.info_popup) {
            this.info_popup.close(gmap.gmap, this);
            this.info_popup = null;
          }
          else {
            this.info_popup = new google.maps.InfoWindow({ content: this.info });
            this.info_popup.open(gmap.gmap, this);
          }
        });
      });
      
      gmap.centerMap(loc);
    }
    
    if (gmap.map_ready) {
      gmap.on('mapready', set_markers, this);
    }
    else {
      set_markers.call(this);
    }
  },
  
  _build_gmap_marker_info: function(record)
  {
    var addr_elems    = record.get("school_addr").split(",");    
    var marker_info   = '<div class="school_marker_info">';
    marker_info      += "<b>School Name: </b>" + record.get("school_name") + "<br/>";
    marker_info      += '<b>Absentee Rate: </b>'+Math.round(record.get("absentee_rate")*100)/100+'%<br/>';
    marker_info      += '<b>Deviation Rate: </b>'+Math.round(record.get("deviation")*100)/100+'%<br/>';
    marker_info      += '<b>Severity: </b>'+Math.round(record.get("severity")*100)/100+'%<br/>';    
    marker_info      += '<br/><br/>';
    marker_info      += addr_elems[0] + "<br/>" + addr_elems[1] + "<br/>" + addr_elems.slice(2).join(",");
    marker_info      += '</div>';
    return marker_info;
  }
});
