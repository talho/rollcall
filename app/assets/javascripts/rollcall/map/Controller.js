//= require_tree ./view
//= require ext_extensions/GMapPanel

Ext.namespace('Talho.Rollcall.Map');

Talho.Rollcall.Map.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
    this.layout = new Talho.Rollcall.Map.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }

    Talho.Rollcall.Map.Controller.superclass.constructor.call(this);
  },
});

Talho.ScriptManager.reg("Talho.Rollcall.Map", Talho.Rollcall.Map.Controller, function (config) {
  var cont = new Talho.Rollcall.Map.Controller(config);
  return cont.getPanel();
});