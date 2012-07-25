//= require rollcall/ADST/view/Parameters
//= require rollcall/ADST/view/ResultsLegend
//= require rollcall/ADST/view/Results

Ext.namespace("Talho.Rollcall.ADST.view");

//TODO fix type
Talho.Rollcall.ADST.view.SearchForm = Ext.extend(Ext.FormPanel, {
  itemId: 'ADSTFormPanel',
  labelAlign: 'top',
  id: "ADSTFormPanel",
  url: '/rollcall/adst',
  buttonAlign: 'left',
  columnWidth: 1,
  
  constructor: function (config) {
    Talho.Rollcall.ADST.view.SearchForm.superclass.constructor.apply(this, config);
    
    this.items = [
      new Talho.Rollcall.ADST.view.Parameters(),
      new Talho.Rollcall.ADST.view.ResultsLegend(),
      new Talho.Rollcall.ADST.view.Results()
    ];
    
    this.bbar = new Ext.PagingToolbar(
      {scope: this, displayInfo: true, prependButtons: true, pageSize: 6,
        listeners: {
          //TODO bubble next page up to controller
          'beforechange': function () {  }
        }
      }
    )
  }
});