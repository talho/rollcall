//= require rollcall/ADST/view/Parameters
//= require rollcall/ADST/view/Results

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.SearchForm = Ext.extend(Ext.FormPanel, {
  itemId: 'ADSTFormPanel',
  id: "ADSTFormPanel",
  url: '/rollcall/adst',
  labelAlign: 'top',
  buttonAlign: 'left',
  
    
  initComponent: function (config) {
    var parameters = new Talho.Rollcall.ADST.view.Parameters({getBubbleTarget: this.getBubbleTarget});    
    var results = new Talho.Rollcall.ADST.view.Results({getBubbleTarget: this.getBubbleTarget});
    
    this.getParameters = function () { return parameters };    
    this.getResults = function () { return results };
        
    this.items = [      
      parameters,            
      results
    ];
    
    Talho.Rollcall.ADST.view.SearchForm.superclass.initComponent.apply(this, config);       
  },
  
  reset: function () {
    this.getForm().reset();
    this.getParameters().reset();
  }
});