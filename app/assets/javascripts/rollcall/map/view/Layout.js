Ext.namespace("Talho.Rollcall.Map.view");

Talho.Rollcall.Map.view.Layout = Ext.extend(Ext.Panel, {
  id: 'mapping',
  closable: true,
  layout: 'fit',
  border: false,
  defaults: { border: false }
,  title: "Rollcall Mapping", 
  
  initComponent: function () {    
    var store = new Ext.data.JsonStore({
      url: 'rollcall/map',
      method: 'GET',
      root: 'results',      
      idProperty: 'school_id',
      autoLoad: false,      
      fields: ['school_id', 'weight', 'gmap_lat', 'gmap_lng', 'display_name']
    });
    
    this.store = store;
    
    this.gmap = new Ext.ux.GMapPanel({zoomLevel: 6, region: 'center'});
    this.start = new Ext.form.Label();
    this.end = new Ext.form.Label();
    
    this.items = [{xtype: 'panel', layout: 'border', items:[
        this.gmap,
        {xtype: 'panel', region: 'south', height: 100, items: [
          {xtype: 'panel', layout: 'hbox', border: false, items: [
            {xtype: 'button', text: '<<'},
            {xtype: 'spacer', width: 20},
            {xtype: 'label', text: 'start'},
            {xtype: 'spacer', width: 20},
            new Ext.slider.MultiSlider({minValue: 0, maxValue: 7, values: [0], width: 250}),
            {xtype: 'spacer', width: 20},
            {xtype: 'label', text: 'end'},
            {xtype: 'spacer', width: 20},
            {xtype: 'button', text: '>>'}
          ]},
          {xtype: 'button', text: 'Play'}
        ]}
      ]
    }];
      
    this.on('afterrender', this._loadStore, this);
          
    Talho.Rollcall.Map.view.Layout.superclass.initComponent.call(this);
  },
  
  _loadStore: function () {
    this.store.load({callback: this._mapsCheck, scope: this});
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
    
    this.store.each(function (record) {
      var loc = new google.maps.LatLng(record.get("gmap_lat"), record.get("gmap_lng"));
      data.push({
        location: loc,
        weight: parseInt(record.get('weight')) 
      });
      latlngbounds.extend(loc);
    });    
    
    if (!latlngbounds.isEmpty()) {
      this.gmap.gmap.fitBounds(latlngbounds);
    }
    
    var heatmap = new google.maps.visualization.HeatmapLayer({
      data: data,
      map: this.gmap.gmap,
      opacity: .6
    });          
  }
});