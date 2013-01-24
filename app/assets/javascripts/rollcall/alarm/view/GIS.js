Ext.namespace("Talho.Rollcall.alarm.view");

Talho.Rollcall.alarm.view.GIS = Ext.extend(Ext.Window, {
  layout: 'fit',
  
  initComponent: function () {
    var windowSize = Ext.getBody().getViewSize();
    this.width = windowSize.width - 40;
    this.height = windowSize.height - 40;
    this.title = "My Schools in an Alarm State";
    
    var store = new Ext.data.JsonStore({
      url: 'rollcall/get_gis',
      root: 'results',
      totalProperty: 'total_results',
      idProperty: 'school_name',
      autoLoad: false,
      autoDestroy: true,      
      fields: ['school_name', 'absentee_rate', 'deviation', 'severity', 'school_addr', 'school_lat', 'school_lng']
    });
    
    this.store = store;
    
    this.gmap = new Ext.ux.GMapPanel({zoomLevel: 6});
    
    this.items = [this.gmap];
      
    this.on('afterrender', this._loadStore, this);
          
    Talho.Rollcall.alarm.view.GIS.superclass.initComponent.call(this);
  },
  
  _loadStore: function () {
    this.store.load({callback: this._render_gmap_markers, scope: this});
  },
  
  _render_gmap_markers: function () {
    if (this.gmap.map_ready) {
      this._set_markers.call(this);
    }
    else {      
      this.gmap.on('mapready', this._set_markers, this);
    }
  },
  
  _build_gmap_marker_info: function (record) {
    var addr_elems    = record.get('school_addr').split(','); 
       
    var marker_info = '<div class="school_marker_info">';
    marker_info += "<b>School Name: </b>" + record.get("school_name") + "<br/>";
    marker_info += '<b>Absentee Rate: </b>' + Math.round(record.get("absentee_rate")*100)/100 + '%<br/>';
    marker_info += '<b>Deviation Rate: </b>' + Math.round(record.get("deviation")*100)/100 + '%<br/>';
    marker_info += '<b>Severity: </b>' + Math.round(record.get("severity")*100)/100 + '%<br/>';    
    marker_info += '<br/><br/>';
    marker_info += addr_elems[0] + "<br/>" + addr_elems[1] + "<br/>" + addr_elems.slice(2).join(",");
    marker_info += '</div>';
    
    return marker_info;
  },
  
  _set_markers: function () {        
    var latlngbounds = new google.maps.LatLngBounds();
    
    this.store.each(function (record) {
      var color = "ffa500";
      loc = new google.maps.LatLng(record.get("school_lat"), record.get("school_lng"));
      latlngbounds.extend(loc);
      
      var marker = this.gmap.addStyledMarker(loc, record.get("school_name"), { color: color });        
      marker.info = this._build_gmap_marker_info(record);
      marker.info_popup = null;
      
      google.maps.event.addListener(marker, 'click', function () {
        if (this.info_popup) {
          this.info_popup.close(this.gmap.gmap, this);
          this.info_popup = null;
        }
        else {
          this.info_popup = new google.maps.InfoWindow({ content: this.info });
          this.info_popup.open(this.gmap.gmap, this);
        }
      });     
    }, this);
    
    if (!latlngbounds.isEmpty()) {
      this.gmap.gmap.fitBounds(latlngbounds);
    }
  }
});
