
Ext.namespace("Talho.Rollcall.alarm.view.alarm");

Talho.Rollcall.alarm.view.alarm.Show = Ext.extend(Ext.Panel, { 
  layout: 'fit',
  
  initComponent: function () {
    new Ext.data.JsonStore({
      url: 'rollcall/get_info' + this.alarm_id,
      root: 'alarm',
      fields: ['school_name', 'school_id', 'report_date', 'reason', 'deviation', 'severity', 'ignore_alarm', 'school_info'],
      autoLoad: true
    });
    
    var tpl = new Ext.XTemplate(
      '<h1>{school_name}</h1>',
      '{report_date} - {reason}'
    );
    
    this.items = [
      {xtype: 'dataview', store: store, tpl: tpl},
      {xtype: 'button', text: 'Ignore'},
      {xtype: 'button', text: 'Delete'},
      {xtype: 'panel', html: '<p>GIS THING HERE</p>'}
    ];
    
    Talho.Rollcall.alarm.view.alarm.Show.superclass.initComponent.call(this);
  }
});