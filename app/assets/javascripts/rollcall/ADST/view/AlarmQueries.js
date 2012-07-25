//TODO: Require Files

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.AlarmQueries = Ext.extend(Ext.Panel, {
  autoScroll: true,
  layout:     'fit',

  constructor: function (config) {
    // this.items = [
      // //TODO: Fill with ADSTAlarmsPanel
      // new Talho.Rollcall.ADST.view.ADSTAlarmsPanel({}),
    // ];
    
    Talho.Rollcall.ADST.view.AlarmQueries.superclass.constructor.apply(this, config);        
  }
});
