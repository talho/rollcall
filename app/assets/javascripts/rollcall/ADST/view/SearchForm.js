//= require rollcall/ADST/view/Parameters
//= require rollcall/ADST/view/ResultsLegend
//= require rollcall/ADST/view/Results

Ext.namespace("Talho.Rollcall.ADST.view");

//TODO fix type
Talho.Rollcall.ADST.view.SearchForm = Ext.extend(Ext.FormPanel, {
  itemId: 'ADSTFormPanel',
  id: "ADSTFormPanel",
  url: '/rollcall/adst',
  labelAlign: 'top',
  buttonAlign: 'left',
  
  initComponent: function (config) {
    this.items = [      
      new Talho.Rollcall.ADST.view.Parameters({getBubbleTarget: this.getBubbleTarget}),      
      new Talho.Rollcall.ADST.view.ResultsLegend({getBubbleTarget: this.getBubbleTarget}),
      new Talho.Rollcall.ADST.view.Results({getBubbleTarget: this.getBubbleTarget})
    ];
    
    Talho.Rollcall.ADST.view.SearchForm.superclass.initComponent.apply(this, config);       
  }
});