//= require rollcall/ADST/view/SimpleParameters
//= require rollcall/ADST/view/AdvancedParameters

Ext.namespace("Talho.Rollcall.ADST.view");

//TODO fix type
Talho.Rollcall.ADST.view.Parameters = Ext.extend(Ext.Panel, {
  id: 'parameters',
  borders: 'true',
  collapsible: false,
  layout: 'fit',

  initComponent: function (config) {    
    this.items = [];
    
    //TODO if store fails no auth and keel everytin up on controller
    //TODO switch to ajax request instead of store
    
    Ext.Ajax.request({
      url: '/rollcall/query_options',
      method: 'GET',
      scope: this,
      success: function (response) {
        var data = Ext.decode(response.responseText);
        this.items.add(new Talho.Rollcall.ADST.view.SimpleParameters({options: data.options, getBubbleTarget: this.getBubbleTarget}));
        this.items.add(new Talho.Rollcall.ADST.view.AdvancedParameters({options: data.options, getBubbleTarget: this.getBubbleTarget}));
        this.doLayout();
      }
    });        
    
    Talho.Rollcall.ADST.view.Parameters.superclass.initComponent.apply(this, config);        
  },
  
  //TODO make it toggle between simple and advanced
  toggle: function () {
    
  }
});