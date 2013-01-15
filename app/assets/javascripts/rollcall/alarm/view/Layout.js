
Ext.namespace("Talho.Rollcall.alarm.view");

Talho.Rollcall.alarm.view.Layout = Ext.extend(Ext.Panel, {
  id: 'rollcallalarms',
  closable: true,
  layout: 'fit',
  border: false,
  title: 'Rollcall Alarms',
  
  initComponent: function () {
    var me = this,
        findBubble = function () {
          return me;
        };
    
    var queries = new Talho.Rollcall.alarm.view.alarmquery.Index({region: 'west', width: 400, getBubbleTarget: findBubble});
    this.center = new Talho.Rollcall.alarm.view.alarm.Index({region: 'center', getBubbleTarget: findBubble});    
    
    this.items = {xtype: 'panel', layout: 'border', autoScroll: true, scope: this,
      items: [
        queries,
        this.center        
      ]
    };        
    
    Talho.Rollcall.alarm.view.Layout.superclass.initComponent.call(this);
  }
});
