//= require ext_extensions/Graph

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.GraphWindow = Ext.extend(Ext.Window, {
  modal: true,
  resizeable: false,
  draggable: false,
  layout: 'fit',
  initComponent: function () {    
    var windowSize = Ext.getBody().getViewSize();
    this.width = windowSize.width - 40;
    this.height = windowSize.height - 40;
    this.school_data = undefined; 
    
    this.combo = new Ext.form.ComboBox({
        valueField: 'id',
        displayField: 'name',
        store: new Ext.data.JsonStore({
          root: 'results',
          autoLoad: true, url: 'rollcall/search_results', fields: ['id', 'name'], 
          baseParams: this.search_params
      })
    });
    
    //TODO SETUP School MODE
    //TODO MASKING
    
    this.bbar = new Ext.Toolbar({
      layout: 'hbox',
      items: [
        {xtype: 'container', flex: 1, items: [{xtype: 'button', text: 'Previous'}]},
        {xtype: 'container', width: 'auto', items: [this.combo]},        
        {xtype: 'container', flex: 1, items: [{xtype: 'button', style: {'float': 'right'}, text: 'Next'}]},
      ]
    });
    
    this._loadGraph();
    
    Talho.Rollcall.ADST.view.GraphWindow.superclass.initComponent.apply(this, arguments)
  },
  
  _nextGraph: function () {
    this.graphNumber += 1;
    this._loadGraph();
  },
  
  _previousGraph: function () {
    this.graphNumber -= 1;
    this._loadGraph();
  },
  
  _loadGraph: function (graphNumber) {
    //TODO Mask this
    if (graphNumber) { this.graphNumber = graphNumber; }
    
    var school = this.store.getAt(this.graphNumber);
    var field_array = this._getFieldArray(school);
    var school_store = new Ext.data.JsonStore({fields: field_array, data: school.get('results')});
    
    this.title = school.get('name');
    
    this.items = new Talho.ux.Graph({
      store: school_store,
      width: this.width - 40,
      height: this.height - 60,
      series: this.graph_series
    });
    
    this.doLayout();
  }
});
