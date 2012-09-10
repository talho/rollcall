//= require rollcall/ADST/view/SimpleParameters
//= require rollcall/ADST/view/AdvancedParameters

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.Parameters = Ext.extend(Ext.Panel, {
  id: 'parameters',
  collapsible: false,
  layout: 'fit',
  border: false,
  cls: 'rollcall-top-padding',

  initComponent: function (config) {    
    this.addEvents('notauthorized', 'toggle');
    this.enableBubble('notauthorized');
    
    this.simple_mode = true;
    
    this.getSimplePanel = function () {
      if (!this.simple_panel) {
        this.simple_panel = new Talho.Rollcall.ADST.view.SimpleParameters({getBubbleTarget: this.getBubbleTarget});
      }
      if (this.data) {this.simple_panel.loadOptions(this.data)}
      return this.simple_panel;      
    };
    
    this.getAdvancedPanel = function () {
      if (!this.advanced_panel) {
        this.advanced_panel = new Talho.Rollcall.ADST.view.AdvancedParameters({getBubbleTarget: this.getBubbleTarget});
      }
      if (this.data) {this.advanced_panel.loadOptions(this.data)}
      return this.advanced_panel;
    };
    
    // var school_check = new Ext.form.Checkbox({id: 'return_individual_school', checked: true, 
      // boxLabel: "Return Individual School Results"
    // });
    
    this.items = [this.getSimplePanel()];
    
    //TODO if store fails no auth and keel everytin up on controller    
    
    Ext.Ajax.request({
      url: '/rollcall/query_options',
      method: 'GET',
      scope: this,
      success: function (response) {
        this.data = Ext.decode(response.responseText);
        this.getSimplePanel().loadOptions(this.data);
        this.getAdvancedPanel().loadOptions(this.data);
        this.doLayout();
      },
      failure: function (response) {
        this.fireEvent('notauthorized');
      }
    });               
    
    Talho.Rollcall.ADST.view.Parameters.superclass.initComponent.apply(this, config);        
  },
  
  getParameters: function () {
    if (!this.simple_mode) {
      return this.getAdvancedPanel().getListBoxes();
    }
  },
    
  toggle: function () {
    if (this.simple_mode) {
      this.remove(this.getSimplePanel());
      this.simple_panel = false   
      this.add(this.getAdvancedPanel());      
      var button_text = "Switch to Simple View";
    }
    else {
      this.remove(this.getAdvancedPanel());
      this.advanced_panel = false
      this.add(this.getSimplePanel());            
      var button_text = "Switch to Advanced View";
    }    
    this.simple_mode = !this.simple_mode    
    this.doLayout();
  },
  
  reset: function () {
    this.getAdvancedPanel().reset();
  }
});