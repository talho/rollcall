Ext.namespace("Talho.Rollcall.tutorial.view");

Talho.Rollcall.tutorial.view.Index = Ext.extend(Ext.Panel, {
  layout: 'fit',
  cls: 'status-index', 
  
  initComponent: function () {
    this.player = new Ext.ux.YouTubePlayer({anchor: '100%', border: false});
    
    this.items = [{xtype: 'panel', layout: 'anchor', align: 'center', cls: 'youtube', autoScroll: true,
      items: [{xtype: 'spacer', height: 30},
              new Ext.Panel({border: false, items: this.player}),
              {xtype: 'spacer', height: 30},
              new Ext.ux.YouTubeList({anchor: '100%', border: false, getBubbleTarget: this.getBubbleTarget})]}
    ];        
    
    Talho.Rollcall.tutorial.view.Index.superclass.initComponent.apply(this, arguments);
  },
  
  loadVideo: function (videoUrl, autoPlay) {    
    this.player.loadVideo(videoUrl, autoPlay);
  }
});