Ext.namespace("Talho.Rollcall.Map.view");

Talho.Rollcall.Map.view.Layout = Ext.extend(Ext.Panel, {
  id: 'mapping',
  closable: true,
  layout: 'fit',
  border: false,
  defaults: { border: false },
  title: "Rollcall Mapping",
  
  initComponent: function () {  
    this.gmap = new Ext.ux.GMapPanel({zoomLevel: 6, region: 'center'});
    this.start = new Ext.form.Label({text: '2013-01-31'});
    this.end = new Ext.form.Label({text: '2013-01-31'});    
    this.date_label = new Ext.form.Label({text: 'Displaying School Districts on current date'});
    this.slider = new Ext.slider.MultiSlider({minValue: 0, values: [0], width: 250});
    this.displaying = new Ext.form.Label({});
    this.control_panel = new Ext.Panel({region: 'south', height: 100, items: [
      {xtype: 'panel', layout: 'hbox', border: false, layoutConfig: { padding:'5', pack:'center', align:'middle' }, items: [
        {xtype: 'button', text: '<<', scope: this, handler: function () { this._setDate(this.date_index - 1); }},            
        {xtype: 'spacer', width: 20},
        this.start,
        {xtype: 'spacer', width: 20},
        this.slider,
        {xtype: 'spacer', width: 20},
        this.end,
        {xtype: 'spacer', width: 20},
        {xtype: 'button', text: '>>', scope: this, handler: function () { this._setDate(this.date_index + 1); }}
      ]},
      {xtype: 'panel', layout: 'hbox', border: false, layoutConfig: { padding:'5', pack:'center', align:'middle' }, items: [ this.date_label ]}      
    ]});
    
    this.items = [{xtype: 'panel', layout: 'border', items:[
        this.gmap,
        this.control_panel
      ]
    }];
      
    this.date_mode = "sd";
      
    Ext.Ajax.request({
      url: '/rollcall/map',
      method: 'GET',
      scope: this,
      params: {school_district: true},
      success: function (response) {
        var data = Ext.decode(response.responseText);
        this._loadData(data);                 
      }      
    });
          
    Talho.Rollcall.Map.view.Layout.superclass.initComponent.call(this);
  },
  
  _loadData: function (data) {
    this.start.setText(data.start);
    this.end.setText(data.end);
    this.data = data.results;
    this.date = this.data[0].date;
    this.date_label.setText('Displaying ' + (this.data_mode == "sd" ? 'School Districts' : 'Schools') + ' on ' + this.date);
    this.date_index = 0;
    this.slider.setMaxValue(this.data.length);
    this.slider.addListener('change', function (slider, newValue, thumb) {
      this._setDate(newValue);
    }, this)

    this._mapsCheck();
  },
  
  _mapsCheck: function () {
    if (this.gmap.map_ready) {
      this._renderGmapOverlays.call(this);
    }
    else {      
      this.gmap.on('mapready', this._renderGmapOverlays, this);
    }
  },
  
  _renderGmapOverlays: function () {
    var latlngbounds = new google.maps.LatLngBounds();
    var data = new google.maps.MVCArray();
    
    Ext.each(this.data, function (record) {
      if (record.date == this.date) {
        Ext.each(record.schools, function (school) {
          var loc = new google.maps.LatLng(school.gmap_lat, school.gmap_lng);
          data.push({
            location: loc,
            weight: parseInt(school.weight) 
          });
          latlngbounds.extend(loc);
        });
      }
    });    
    
    if (!latlngbounds.isEmpty() && !this.centered) {
      this.gmap.gmap.fitBounds(latlngbounds);
      this.centered = true;
    }
    
    var gmap = this.gmap.gmap;
    
    if (!this.heatmap) {
      this.heatmap = new google.maps.visualization.HeatmapLayer({      
        map: this.gmap.gmap,
        opacity: .6,
        radius: this._getRadius(gmap),
        maxIntensity: 100
      });
    }
    
    var heatmap = this.heatmap;
    var getRadius = this._getRadius;
    
    google.maps.event.addListener(gmap, 'zoom_changed', function() {
      if (gmap.getZoom() > 8) {
        Ext.getCmp("mapping")._setDataMode("s");
        heatmap.setOptions({radius: getRadius(gmap)});
      }
      else {
        Ext.getCmp("mapping")._setDataMode("sd");
        heatmap.setOptions({radius: getRadius(gmap)});
      }
    });
    
    this.heatmap.setData(data);    
    this.heatmap.setMap(this.gmap.gmap);
  },
  
  _setDate: function (index) {
    if (index < 0) {
     index = this.data.length - 1;     
    }
    else if (index > this.data.length - 1) {
      index = 0;
    }
    
    this.date_index = parseInt(index);
    this.slider.setValue(0, this.date_index); 
    this.date = this.data[this.date_index].date;
    
    this.date_label.setText('Displaying ' + (this.data_mode == "sd" ? 'School Districts' : 'Schools') + ' on ' + this.date);         
    
    this._renderGmapOverlays();    
  },
  
  _getRadius: function (gmap) {
    var radii = [2,2,3,3,4,6,8,10,12,5,5,5,6,6,10,10,10,10,10,10,10];
    
    return radii[gmap.getZoom()];
  },
  
  _setDataMode: function (mode) {
    if (mode != this.data_mode) {
      this.data_mode = mode;
      this.heatmap.setMap(null);
      if (this.data_mode == "sd") {
        this.displaying.setText("Displaying: School Districts");
        Ext.Ajax.request({
          url: '/rollcall/map',
          method: 'GET',
          scope: this,
          params: {school_district: true},
          success: function (response) {
            var data = Ext.decode(response.responseText);
            this._loadData(data);                 
          }      
        });
      }
      else {
        this.displaying.setText("Displaying: Schools");
        Ext.Ajax.request({
          url: '/rollcall/map',
          method: 'GET',
          scope: this,          
          success: function (response) {
            var data = Ext.decode(response.responseText);
            this._loadData(data);                 
          }      
        });
      }      
    }
  }
});