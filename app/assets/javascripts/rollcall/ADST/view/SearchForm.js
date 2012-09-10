//= require rollcall/ADST/view/Parameters


Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.SearchForm = Ext.extend(Ext.FormPanel, {
  itemId: 'ADSTFormPanel',
  id: "ADSTFormPanel",
  url: '/rollcall/adst',
  labelAlign: 'top',
  buttonAlign: 'left',
  border: false,
    
  initComponent: function (config) {    
    this.addEvents('reset', 'submitquery', 'exportresult', 'saveasalarm', 'showreportmessage');        
    this.enableBubble(['reset', 'submitquery', 'exportresult', 'saveasalarm', 'showreportmessage']);
    
    var parameters = new Talho.Rollcall.ADST.view.Parameters({getBubbleTarget: this.getBubbleTarget});        
    
    this.getParametersPanel = function () { return parameters }; 
        
    this.items = [parameters];
    
    // this.buttons = [      
      // {text: "Submit", scope: this, handler: function () { this.fireEvent('submitquery', this.getParams());  this._showButtons() }},
      // {text: "Clear Parameters", scope: this, handler: function () { this.fireEvent('reset'); }},
      // {text: "Export Result Set", hidden: true, scope: this, handler: function () { this.fireEvent('exportresult') }},
      // {text: "Create Alarm from Result Set", hidden: true, scope: this, handler: function () { this.fireEvent('saveasalarm'); }},
      // {text: "Generate Report from Result Set", hidden: true, scope: this,
        // handler: function (button, firedEvent) { this._showReportMenu(button.getEl(), null) }
      // }
    // ];
    
    this.school_mode = true;
    
    Talho.Rollcall.ADST.view.SearchForm.superclass.initComponent.apply(this, config);       
  },
  
  getParams: function () {
    params = new Object;
    
    form_values = this.getForm().getValues();
    for (key in form_values) {
      if (form_values[key].indexOf('...') == -1) { 
        params[key] = form_values[key].replace(/\+/g, " ");
      }
    }
    
    if (this.school_mode) {
      params['return_individual_school'] = 'on';
    }
        
    var lists_box_params = this.getParametersPanel().getParameters();
        
    Ext.apply(params, lists_box_params);
    
    return params;
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
  },           
  
  _showReportMenu: function(element, school_id) {
    var scrollMenu = new Ext.menu.Menu();
    scrollMenu.add({ text: 'Attendance Report', handler: function () {
      this.fireEvent('showreportmessage', 'RecipeInternal::AttendanceAllRecipe', school_id); }, scope: this 
    });
    scrollMenu.add({school_id: school_id, recipe: 'RecipeInternal::IliAllRecipe', text: 'ILI Report', handler: function () {      
      this.fireEvent('showreportmessage', 'RecipeInternal::IliAllRecipe', school_id); }, scope: this
    });
    scrollMenu.show(element);
  },
  
  _setIndividualValue: function (value) {
    this.school_mode = value;
  }
});