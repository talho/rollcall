Ext.namespace("Talho.Rollcall.ADST.view");

//TODO fix type
Talho.Rollcall.ADST.view.ActionButtons = Ext.extend(Ext.Panel, {
  layout: 'auto',
  hidden: false,
  
  constructor: function (config) {
    this.addEvents('reset', 'submitquery');        
    this.enableBubble('submitquery');
    this.enableBubble('reset');
    
    
    Talho.Rollcall.ADST.view.ActionButtons.superclass.constructor.apply(this, config);
  },
  
  initComponent: function (config) {        
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
      
    Talho.Rollcall.ADST.view.ActionButtons.superclass.initComponent.apply(this, config);
  }
});