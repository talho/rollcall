//= require rollcall/Graphing/view/SimpleParameters
//= require rollcall/Graphing/view/AdvancedParameters

Ext.namespace("Talho.Rollcall.Graphing.view");

Talho.Rollcall.Graphing.view.Parameters = Ext.extend(Ext.Panel, {
  id: 'parameters',
  collapsible: false,
  layout: 'fit',
  border: false,
  cls: 'rollcall-top-padding',

  initComponent: function (config) {    
    this.addEvents('notauthorized', 'toggle', 'showgraphingmask');
    this.enableBubble(['notauthorized', 'showgraphingmask']);
    
    this.simple_mode = true;
    
    this.getSimplePanel = function () {
      if (!this.simple_panel) {
        this.simple_panel = new Talho.Rollcall.Graphing.view.SimpleParameters({getBubbleTarget: this.getBubbleTarget});
      }
      if (this.data) {this.simple_panel.loadOptions(this.data)}
      return this.simple_panel;      
    };
    
    this.getAdvancedPanel = function () {
      if (!this.advanced_panel) {
        this.advanced_panel = new Talho.Rollcall.Graphing.view.AdvancedParameters({getBubbleTarget: this.getBubbleTarget});
      }
      if (this.data) {this.advanced_panel.loadOptions(this.data)}
      return this.advanced_panel;
    };

    
    this.items = [this.getSimplePanel()];

    Ext.Ajax.request({
      url: '/rollcall/query_options',
      method: 'GET',
      scope: this,
      success: function (response) {
        this.fireEvent('showgraphingmask');
        this.data = Ext.decode(response.responseText);
        this.getSimplePanel().loadOptions(this.data);
        this.getAdvancedPanel().loadOptions(this.data);
        this.doLayout();
      },
      failure: function (response) {
        this.fireEvent('notauthorized');        
      }
    });               
    
    Talho.Rollcall.Graphing.view.Parameters.superclass.initComponent.call(this);        
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