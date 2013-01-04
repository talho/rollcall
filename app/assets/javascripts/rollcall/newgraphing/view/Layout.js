//= require ext_extensions/DoNotCollapseActive
//= require rollcall/ux/ComboBox.js
//= require rollcall/ux/Filter
//= require rollcall/Graphing/view/Results

Ext.namespace("Talho.Rollcall.newGraphing.view");

Talho.Rollcall.newGraphing.view.Layout = Ext.extend(Ext.Panel, {
  id: 'newgraphing',
  closable: true,
  layout: 'fit',
  border: false,
  title: "Rollcall Graphing",  
  
  initComponent: function () {
    
    var me = this,
        findBubble = function () {
          return me;
        };
    
    this.basic = new Talho.Rollcall.graphing.view.filter.Basic();
    
    this.demographic = new Talho.Rollcall.graphing.view.filter.Demographic();
    
    this.school = new Talho.Rollcall.graphing.view.filter.School();
    
    this.symptom = new Talho.Rollcall.graphing.view.filter.Symptom();
    
    this.common = new Talho.Rollcall.graphing.view.filter.Common({ anchor: '100% 25%' });
    
    this.filters = [this.basic, this.demographic, this.school, this.symptom, this.common];
    
    this.results = new Talho.Rollcall.graphing.view.Results({region: 'center'});
    
    var submit = {xtype: 'button', text: "Submit", scope: this, handler: function () { this.fireEvent('submitquery'); }};
    
    var reset = {xtype: 'button', text: "Reset", scope: this, handler: function () { this.fireEvent('reset'); }};
    
    this.submit = new Ext.Panel({ border: false, minHeight: 30, buttons: [reset, submit], anchor: '100% 5%' });
    
    this.accordion = new Ext.Panel({
      layout: 'accordion', anchor: '100% 70%',   
      layoutConfig: { hideCollapseTool: true, animate: Application.rails_environment !== 'cucumber' ? true : false },
      activeItem: 0, plugins: ['donotcollapseactive'], cls: 'rollcall-navigation-accordion',
      defaults: { border: false },
      items: [this.basic, this.demographic, this.school, this.symptom, this.common]
    });
    
    this.items = {id: 'new_graphing_layout', layout: 'border', autoScroll: true, scope: this,
      items: [        
        {xtype: 'panel', region: 'east', layout: 'anchor', width: 275, 
          items: [this.common, this.accordion, this.submit]},
        this.results
      ]
    };
    
    var bubbles = [this.basic, this.demographic, this.school, this.symptom, this.common];
    
    Ext.each(bubbles, function (bubble) {
      bubble.getBubbleTarget = findBubble;
    });
   
    Talho.Rollcall.newGraphing.view.Layout.superclass.initComponent.call(this); 
  },
  
  getParameters: function () {
    var params = new Object;
    
    params['start'] = 0;
    params['limit'] = 6;
    
    Ext.each(this.filters, function (filter) {
      var filterParams = filter.getParameters();
      for (key in filterParams) {
        params[key] = filterParams[key];
      }
    });
    
    return params;
  }
});
