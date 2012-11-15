//= require rollcall/tutorial/view/Index

Ext.namespace("Talho.Rollcall.tutorial.view");

Talho.Rollcall.tutorial.view.Layout = Ext.extend(Ext.Panel, {
  id: 'tutorial',
  closable: true,
  layout: 'fit',
  border: false,
  title: 'Rollcall Tutoiral',
  
  initComponent: function () {
    var index = new Talho.Rollcall.tutorial.view.Index();
    
    this.items = [index];
    
    Talho.Rollcall.tutorial.view.Layout.superclass.initComponent.apply(this, arguments);
  },
});
