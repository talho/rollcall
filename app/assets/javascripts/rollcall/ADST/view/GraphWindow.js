//= require ext_extensions/Graph

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.GraphWindow = Ext.extend(Ext.Window, {
  modal: true,
  resizeable: false,
  dragable: false,
  layout: 'fit',
  initComponent: function () {
    this.addEvents('loadgraph');
    this.enableBubble(['loadgraph']);
    
    var windowSize = Ext.getBody().getViewSize();
    this.width = windowSize.width - 40;
    this.height = windowSize.height - 40;    
    
    this.bbar = [
      {xtype: 'combo', value: 'school'},
      '->',      
      {xtype: 'button', text: 'Previous'},
      {xtype: 'button', text: 'Next'}
    ];        
    
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
