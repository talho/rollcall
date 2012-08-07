//= require rollcall/ADST/view/Parameters


Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.SearchForm = Ext.extend(Ext.FormPanel, {
  itemId: 'ADSTFormPanel',
  id: "ADSTFormPanel",
  url: '/rollcall/adst',
  labelAlign: 'top',
  buttonAlign: 'left',
    
  initComponent: function (config) {    
    this.addEvents('reset', 'submitquery');        
    this.enableBubble('submitquery');
    this.enableBubble('reset');
    
    var parameters = new Talho.Rollcall.ADST.view.Parameters({getBubbleTarget: this.getBubbleTarget});        
    
    this.getParametersPanel = function () { return parameters }; 
        
    this.items = [parameters];
    
    this.buttons = [
      //TODO move handlers up to controller
      {text: "Submit", itemId: 'submit_ext4', scope: this, handler: function () { this.fireEvent('submitquery'); }, formBind: true},
      {text: "Reset Form", scope: this, handler: function () { this.fireEvent('reset'); }},
      {text: "Export Result Set", hidden: true, scope: this, handler: this._exportResultSet},
      {text: "Create Alarm from Result Set", hidden: true, scope: this, handler: this.saveResultSet},
      {text: "Generate Report from Result Set", hidden: true, scope: this,
        handler: function (buttonObj, eventObj) {
          this._showReportMenu(buttonObj.getEl(), null);
        }
      }
    ];
    
    Talho.Rollcall.ADST.view.SearchForm.superclass.initComponent.apply(this, config);       
  },
  
  reset: function () {
    this.getForm().reset();
    this.getParameters().reset();
  }
});