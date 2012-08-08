//= require rollcall/ADST/view/Parameters


Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.SearchForm = Ext.extend(Ext.FormPanel, {
  itemId: 'ADSTFormPanel',
  id: "ADSTFormPanel",
  url: '/rollcall/adst',
  labelAlign: 'top',
  buttonAlign: 'left',
    
  initComponent: function (config) {    
    this.addEvents('reset', 'submitquery', 'exportresult', 'saveasalarm', 'createreport');        
    this.enableBubble(['reset', 'submitquery', 'exportresult', 'saveasalarm', 'createreport']);
    
    var parameters = new Talho.Rollcall.ADST.view.Parameters({getBubbleTarget: this.getBubbleTarget});        
    
    this.getParametersPanel = function () { return parameters }; 
        
    this.items = [parameters];
    
    this.buttons = [
      //TODO move handlers up to controller
      {text: "Submit", itemId: 'submit_ext4', scope: this, handler: function () { this.fireEvent('submitquery', this.getParams());  this._showButtons() }, formBind: true},
      {text: "Reset Form", scope: this, handler: function () { this.fireEvent('reset'); }},
      {text: "Export Result Set", hidden: true, scope: this, handler: function () { this.fireEvent('exportresult') }},
      {text: "Create Alarm from Result Set", hidden: true, scope: this, handler: function () { this.fireEvent('saveasalarm'); }},
      {text: "Generate Report from Result Set", hidden: true, scope: this,
        handler: function () { this.fireEvent('createreport'); }
      }
    ];
    
    Talho.Rollcall.ADST.view.SearchForm.superclass.initComponent.apply(this, config);       
  },
  
  getParams: function () {
    form_values = this.getForm().getValues();
    for (key in form_values) {
      if (form_values[key].indexOf('...') != -1) { delete form_values[key] }
    }
    
    return form_values;
  },
  
  reset: function () {
    this.getForm().reset();
    this.getParameters().reset();
  },
  
  toggle: function () {
    this.getParametersPanel().toggle();
  },
  
  _showButtons: function () {
    Ext.each(this.buttons, function (button) {
      if (button.hidden) { button.show(); }
    });
  }
});