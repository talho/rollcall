//= require ext_extensions/DoNotCollapseActive
//= require rollcall/ux/ComboBox.js
//= require rollcall/ux/Filter

Ext.namespace("Talho.Rollcall.newGraphing.view");

Talho.Rollcall.newGraphing.view.Layout = Ext.extend(Ext.Panel, {
  closable: true,
  layout: 'fit',
  border: false,
  title: "Rollcall Graphing",  
  
  initComponent: function () {
    
    var basic = new Talho.Rollcall.graphing.view.filter.Basic();
    
    var demographic = new Talho.Rollcall.graphing.view.filter.Demographic();
    
    var school = new Talho.Rollcall.graphing.view.filter.School();
    
    var symptom = new Talho.Rollcall.graphing.view.filter.Symptom();
    
    var common = new Talho.Rollcall.graphing.view.filter.Common();
    
    this.filters = [basic, demographic, school, symptom, common];
    
    this.saved_searches = new Talho.Rollcall.graphing.view.SavedSearches();
    
    this.accordion = new Ext.Panel({
      layout: 'accordion', anchor: '100% 75%',   
      layoutConfig: { hideCollapseTool: true, animate: Application.rails_environment !== 'cucumber' ? true : false },
      activeItem: 0, plugins: ['donotcollapseactive'], cls: 'rollcall-navigation-accordion',
      defaults: { border: false },
      items: [basic, demographic, school, symptom, common, this.saved_searches]
    })
    
    this.items = {id: 'new_graphing_layout', layout: 'border', autoScroll: true, scope: this,
      items: [        
        {xtype: 'panel', region: 'east', layout: 'anchor', width: 350, 
          items: [this.accordion, common]},
        {xtype: 'panel', region: 'center', html: '<div>this is a center</div>'},
      ]
    }
    
   
   Talho.Rollcall.newGraphing.view.Layout.superclass.initComponent.call(this); 
  }
});
