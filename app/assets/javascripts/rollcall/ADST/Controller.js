//= require ext_extensions/Portal
//= require rollcall/ux/ComboBox.js
//= require rollcall/d3/d3.v2.min.js
//= require rollcall/ADST/view/Layout

Ext.namespace('Talho.Rollcall.ADST');

Talho.Rollcall.ADST.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function (config) {
 
    var layout = new Talho.Rollcall.ADST.view.Layout();
    
    this.getPanel = function () {
      return layout;
    }
    
    //TODO: Set up index events
    Talho.Rollcall.ADST.Controller.superclass.constructor.apply(this, config);
  }
});

Talho.ScriptManager.reg("Talho.Rollcall.ADST", Talho.Rollcall.ADST.Controller, function (config) {
  var cont = new Talho.Rollcall.ADST.Controller(config);
  return cont.getPanel();
});
