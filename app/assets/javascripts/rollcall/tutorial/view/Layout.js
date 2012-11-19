//= require rollcall/tutorial/view/Index

Ext.namespace("Talho.Rollcall.tutorial.view");

Talho.Rollcall.tutorial.view.Layout = Ext.extend(Ext.Panel, {
  id: 'tutorial',
  closable: true,
  layout: 'fit',
  border: false,
  title: 'Rollcall Tutorials',
  
  initComponent: function () {
    var me = this,
      findBubble = function () {
        return me;
    }
    
    this.index = new Talho.Rollcall.tutorial.view.Index({getBubbleTarget: findBubble});
    
    this.items = [this.index];
    
    Talho.Rollcall.tutorial.view.Layout.superclass.initComponent.apply(this, arguments);
  },
  
  loadVideo: function (videoUrl, autoPlay) {
    this.index.loadVideo(videoUrl, autoPlay);
  }
});
