//= require_tree ./view
//= require ext_extensions/GMapPanel

Ext.namespace('Talho.Rollcall.alarm');

Talho.Rollcall.alarm.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
    this.layout = new Talho.Rollcall.alarm.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }
    
    this.layout.on({
      'createalarmquery': this._createAlarmQuery,
      'alarmgis': this._alarmGIS,
      scope: this
    })
    
    Talho.Rollcall.alarm.Controller.superclass.constructor.call(this);
  },
  
  _createAlarmQuery: function () {
    var newquery = new Talho.Rollcall.alarm.view.alarmquery.New();
    newquery.show();
  },
  
  _alarmGIS: function () {
    var wind = new Talho.Rollcall.alarm.view.GIS();
    wind.show();
  }
});

Talho.ScriptManager.reg("Talho.Rollcall.Alarm", Talho.Rollcall.alarm.Controller, function (config) {
  var cont = new Talho.Rollcall.alarm.Controller(config);
  return cont.getPanel();
});