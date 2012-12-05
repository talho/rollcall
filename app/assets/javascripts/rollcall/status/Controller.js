//= require_tree ./view

Ext.namespace('Talho.Rollcall.status');

Talho.Rollcall.status.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
    this.layout = new Talho.Rollcall.status.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }
    
    Talho.Rollcall.status.Controller.superclass.constructor.call(this);
  }
});

Talho.ScriptManager.reg("Talho.Rollcall.Status", Talho.Rollcall.status.Controller, function (config) {
  var cont = new Talho.Rollcall.status.Controller(config);
  return cont.getPanel();
});
