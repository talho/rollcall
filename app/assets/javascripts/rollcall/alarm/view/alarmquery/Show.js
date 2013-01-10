
Ext.namespace("Talho.Rollcall.alarm.view.alarmquery");

Talho.Rollcall.alarm.view.alarmquery.Show = Ext.extend(Ext.Panel, { 
  layout: 'fit',
  
  initComponent: function () {    
    var store = new Ext.data.JsonStore({
        url: String.format('/rollcall/alarm_query/{1}.json',this.alarmqueryid),
        root: 'data',
        autoLoad: true,
        restful: true,
        idProperty: 'id',
        fields: ['name', {name: 'alarm_set', type: 'boolean'}, 'severity', 'deviation', 'schools']
    });
    
    var record = store.getAt(0);
    
    this.name = record.get('name');
    this.set = record.get('alarm_set');
    this.severity = record.get('severity');
    this.deviation = record.get('deviation');
    this.schools = record.get('schools');
    
    var tpl = new Ext.XTemplate(
      '<h1>Schools that will trigger this alarm query</h1>',
      '<ul>',
        '<li>{name}</li>',
      '</ul>'
    );
    
    this.items = [
      {xtype: 'label', text: this.name},
      {xtype: 'label', text: (this.set ? 'This alarm query is enabled' : 'This alarm query is disabled')},
      {xtype: 'label', text: this.severity},
      {xtype: 'label', text: this.deviation},
      {xtype: 'dataview', tpl: tpl, store: new Ext.data.JsonStore({ fields: ['name'], data: this.schools})}
    ]
    
    Talho.Rollcall.alarm.view.alarmquery.Show.superclass.initComponent.call(this);
  }
});