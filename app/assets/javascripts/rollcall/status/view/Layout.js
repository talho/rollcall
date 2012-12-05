//= require rollcall/status/view/Index

Ext.namespace("Talho.Rollcall.status.view");

Talho.Rollcall.status.view.Layout = Ext.extend(Ext.Panel, {
  id: 'status',
  closable: true,
  layout: 'fit',
  border: false,
  title: 'Rollcall Status',
  
  initComponent: function () {
    var index = new Talho.Rollcall.status.view.Index();
    
    this.items = [index];
    
    Talho.Rollcall.status.view.Layout.superclass.initComponent.call(this);
  },
});
