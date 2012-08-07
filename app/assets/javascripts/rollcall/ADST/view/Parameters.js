//= require rollcall/ADST/view/SimpleParameters
//= require rollcall/ADST/view/AdvancedParameters

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.Parameters = Ext.extend(Ext.Panel, {
  id: 'parameters',
  collapsible: false,
  layout: 'fit',

  initComponent: function (config) {    
    this.addEvents('notauthorized', 'toggle');
    this.enableBubble('notauthorized');

    this.items = [];
    
    this.simple_mode = true;
                
    this.toggle_button = new Ext.Button({text: "Switch to Advanced View >>", style:{margin: '0px 0px 5px 5px'}, scope: this,
      handler: function(buttonEl, eventObj) {
        this.toggle();
      }
    });
    
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
    
    this.buttons = [this.toggle_button];
    
    Talho.Rollcall.ADST.view.Parameters.superclass.initComponent.apply(this, config);        
  },
  
  getParams: function () {
    return (this.simple_mode ? this.getSimplePanel().getParams() : this.getAdvancedPanel().getParams());
  },
    
  toggle: function () {
    if (this.simple_mode) {
      this.remove(this.getSimplePanel());
      this.simple_panel = false   
      this.add(this.getAdvancedPanel());
      this.toggle_button.setText("Switch to Simple View >>");
    }
    else {
      this.remove(this.getAdvancedPanel());
      this.advanced_panel = false
      this.add(this.getSimplePanel());      
      this.toggle_button.setText("Switch to Advanced View >>");
    }    
    this.simple_mode = !this.simple_mode    
    this.doLayout();
  },
  
  reset: function () {
    this.getAdvancedPanel().reset();
  }
});