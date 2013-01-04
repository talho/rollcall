//= require_tree ./view

Ext.namespace('Talho.Rollcall.alarm');

Talho.Rollcall.alarm.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
    this.layout = new Talho.Rollcall.alarm.view.Layout();
    
    this.getPanel = function () {
      return this.layout();
    }
  }
});

Talho.ScriptManager.reg("Talho.Rollcall.Alarm", Talho.Rollcall.alarm.Controller, function (config) {
  var cont = new Talho.Rollcall.alarm.Controller(config);
  return cont.getPanel();
});