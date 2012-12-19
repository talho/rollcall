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
    
    this.common = new Talho.Rollcall.graphing.view.filter.Common();
    
    this.filters = [this.basic, this.demographic, this.school, this.symptom, this.common];
    
    this.saved_searches = new Talho.Rollcall.graphing.view.SavedSearches();
    
    this.results = new Talho.Rollcall.Graphing.view.Results({region: 'center'});
    
    this.accordion = new Ext.Panel({
      layout: 'accordion', anchor: '100% 75%',   
      layoutConfig: { hideCollapseTool: true, animate: Application.rails_environment !== 'cucumber' ? true : false },
      activeItem: 0, plugins: ['donotcollapseactive'], cls: 'rollcall-navigation-accordion',
      defaults: { border: false },
      items: [this.basic, this.demographic, this.school, this.symptom, this.common, this.saved_searches]
    });
    
    this.items = {id: 'new_graphing_layout', layout: 'border', autoScroll: true, scope: this,
      items: [        
        {xtype: 'panel', region: 'east', layout: 'anchor', width: 350, 
          items: [this.accordion, this.common]},
        this.results
      ]
    };
    
    var bubbles = [this.basic, this.demographic, this.school, this.symptom, this.common, this.saved_searches];
    
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
