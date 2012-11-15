Ext.namespace("Talho.Rollcall.tutorial.view");

Talho.Rollcall.tutorial.view.Index = Ext.extend(Ext.Panel, {
  layout: 'fit',
  cls: 'status-index',
  
  
  initComponent: function () {
    this.items = [{xtype: 'panel', layout: 'anchor', align: 'center', cls: 'youtube', autoScroll: true,
      items: [new Ext.ux.YouTubePlayer({anchor: '100%', border: false}),
              {xtype: 'spacer', height: 30},
              new Ext.ux.YouTubeList({anchor: '100%', border: false})]}
    ];
    
    Talho.Rollcall.tutorial.view.Index.superclass.initComponent.apply(this, arguments);
  }
});