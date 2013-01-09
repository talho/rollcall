
Ext.namespace("Talho.Rollcall.alarm.view");

Talho.Rollcall.alarm.view.Layout = Ext.extend(Ext.Panel, {
  id: 'rollcallalarms',
  closable: true,
  layout: 'fit',
  border: false,
  title: 'Rollcall Alarms',
  
  initComponent: function () {
    var queries = new Talho.Rollcall.alarm.view.alarmquery.Index({region: 'west', width: 400});
    var alarms = new Talho.Rollcall.alarm.view.alarm.Index({region: 'center'});
    
    this.items = {xtype: 'panel', layout: 'border', autoScroll: true, scope: this,
      items: [
        queries,
        alarms
      ]
    };
    
    Talho.Rollcall.alarm.view.Layout.superclass.initComponent.call(this);
  }
});
