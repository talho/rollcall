//= require ext_extensions/DoNotCollapseActive

Ext.namespace("Talho.Rollcall.newGraphing.view");

Talho.Rollcall.newGraphing.view.Layout = Ext.extend(Ext.Panel, {
  closable: true,
  layout: 'fit',
  border: false,
  title: "Rollcall Graphing",  
  
  initComponent: function () {
    
    this.accordion = new Ext.Panel({
      region: 'west', width: 200, layout: 'accordion',      
      layoutConfig: { hideCollapseTool: true, animate: Application.rails_environment !== 'cucumber' ? true : false },
      activeItem: 0, plugins: ['donotcollapseactive'], cls: 'rollcall-navigation-accordion',
      items: [
        {title: 'Simple', border: false, html: '<div>hue hue hue</div>'},
        {title: 'Advanced',  border: false, html: '<div>hue hue hue</div>'},
        {title: 'Alarms',  border: false, html: '<div>hue hue hue</div>'}
      ]
    })
    
    this.items = {id: 'new_graphing_layout', layout: 'border', autoScroll: true, scope: this,
      items: [
        this.accordion,
        {xtype: 'panel', region: 'center'},
      ]
    }
    
   
   Talho.Rollcall.newGraphing.view.Layout.superclass.initComponent.call(this); 
  }
});
