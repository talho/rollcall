//TODO: Require Files

Ext.namespace("Talho.Rollcall.ADST");

Talho.Rollcall.ADST.AlarmQueries = Ext.extend(Ext.Panel, {
  title:      'Alarm Queries',
  itemId:     'alarm_queries',
  id:         'alarm_queries',
  region:     'south',
  height:     120,
  minSize:    120,
  maxSize:    120,
  autoScroll: true,
  layout:     'fit',

  constructor: function (config) {
    Talho.Rollcall.ADST.view.AlarmQueries.superclass.constructor.apply(this, config);
    
    this.items = [
      //TODO: Fill with ADSTAlarmsPanel
      new Talho.Rollcall.ADSTAlarmsPanel({}),
    ];
  }
});
