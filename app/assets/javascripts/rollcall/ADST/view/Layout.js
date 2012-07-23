//TODO: Require files

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.Layout = Ext.extend(Ext.Panel, {
  id: 'ADSTPanel',
  closable: true,
  initComponent: function () {
    
    Talho.Rollcall.ADST.view.Layout.superclass.initComponent.apply(this, arguments);
    
    this.items = [
      {itemId: 'alarmsPanel'},
      {itemId: 'searchPanel', items: [
        {itemId: 'searchParamatersPanel'},
        {itemId: 'searchResultsPanel'}
      ]},
      {itemId: 'Alarm Queries'}
    ];    
  }
});
