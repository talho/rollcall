//= require ext_extensions/Graph

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.GraphWindow = Ext.extend(Ext.Window, {
  layout: 'fit',
  cls: 'graph-window',
  initComponent: function () {    
    var windowSize = Ext.getBody().getViewSize();
    this.width = windowSize.width - 40;
    this.height = windowSize.height - 40;
    this.origninal_params = this.search_params 
    
    this.combo = new Ext.form.ComboBox({
      valueField: 'id',
      displayField: 'name',
      triggerAction: 'all',
      id: 'graph-window-school',
      scope: this,
      editable: false,
      autoSelect: false,
      allowBlank: false, 
      mode: 'local',
      store: new Ext.data.JsonStore({
        root: 'results',
        autoLoad: false, url: 'rollcall/search_results', fields: ['id', 'name'], 
        params: this.search_params,
        listeners: {
            'load': function () { this.combo.setValue(this.graphNumber); this._loadGraph();    
            this.on('resize', function (win, width, height) { this.width = width; this.height = height; this._loadGraph(); }, this);        
          },
          scope: this
        }
      }),
      listeners: {
        'select': function () { this._loadGraph(); },
        scope: this
      }       
    });

    this.bbar = new Ext.Toolbar({
      layout: 'hbox',
      items: [
        {xtype: 'container', flex: 1, items: [
          {xtype: 'button', text: 'Previous', handler: this._previousGraph, scope: this}
        ]},
        {xtype: 'container', width: 'auto', items: [this.combo]},        
        {xtype: 'container', flex: 1, items: [
          {xtype: 'button', style: {'float': 'right'}, text: 'Next', handler: this._nextGraph, scope: this}
        ]},
      ]
    });
    
    this.combo.getStore().load({params: this.search_params});       
    
    Talho.Rollcall.ADST.view.GraphWindow.superclass.initComponent.apply(this, arguments)
  },
  
  _nextGraph: function () {
    var store = this.combo.getStore();
    var combo_value = this.combo.getValue();
    var school_id = store.find('id', combo_value) + 1;
    if (school_id >= store.getTotalCount()) { school_id = 0; }
    this.school_name = store.getAt(school_id).data.name;
    this.combo.setValue(store.getAt(school_id).data.id);
    this._loadGraph();
  },
  
  _previousGraph: function () {
    var store = this.combo.getStore();
    var combo_value = this.combo.getValue();
    var school_id = store.find('id', combo_value) - 1;
    if (school_id < 0) { school_id = store.getTotalCount() - 1}
    this.school_name = store.getAt(school_id).data.name;
    this.combo.setValue(store.getAt(school_id).data.id);
    this._loadGraph();
  },
  
  _loadGraph: function () {
    var store = this.combo.getStore();
    var combo_value = this.combo.getValue();
    var school_id = store.find('id', combo_value);
    this.school_name = store.getAt(school_id).data.name;  
    
    this.setTitle(this.school_name);
    
    var params = this.search_params    
    
    if ('return_individual_school' in this.search_params && this.search_params['return_individual_school'] == 'on') {
      if ('school_district' in params) { delete params['school_district']; }
      params['school'] = this.school_name;
    }
    else {
      if ('school' in params) { delete params['school']; }
      params['school_district'] = this.school_name;
    }
    
    Ext.Ajax.request({
      url:     '/rollcall/adst',
      method:  'GET',    
      scope:   this,
      params:  params,
      success: function (response) {
        mask = new Ext.LoadMask(this.getEl(), {msg:"Please wait..."});
        mask.show();
        var school = Ext.decode(response.responseText)['results'][0];
        var field_array = this._getFieldArray(school);
        var school_store = new Ext.data.JsonStore({fields: field_array, data: school['results']});
        
        this.items.clear();
        this.items.add(new Talho.ux.Graph({
          store: school_store,
          xField: 'report_date',
          width: this.width - 40,
          height: this.height - 60,
          series: this.graph_series
        }));
        
        this.doLayout(); 
        mask.hide();   
      }
    });
  }
});
