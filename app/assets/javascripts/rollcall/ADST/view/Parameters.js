//= require rollcall/ADST/view/SimpleParameters
//= require rollcall/ADST/view/AdvancedParameters

Ext.namespace("Talho.Rollcall.ADST.view");

//TODO fix type
Talho.Rollcall.ADST.view.Parameters = Ext.extend(Ext.Panel, {

  initComponent: function (config) {
    this.items = new Talho.Rollcall.ADST.view.SimpleParameters({options: records});
    
    Talho.Rollcall.ADST.view.Parameters.superclass.initComponent.apply(this, config);        
  },
  
  //TODO make it toggle between simple and advanced
  toggle: function () {
    
  }
});