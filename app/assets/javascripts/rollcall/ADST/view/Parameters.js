//= require rollcall/ADST/view/SimpleParameters
//= require rollcall/ADST/view/AdvancedParameters
//= require rollcall/ADST/view/ActionPanel

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.Parameters = Ext.extend(Ext.Panel, {
  id: 'parameters',
  borders: 'true',
  collapsible: false,
  layout: 'fit',

  initComponent: function (config) {    
    this.addEvents('notauthorized');
    this.enableBubble('notauthorized');
    
    this.items = [];
    
    this.simple = false;
    
    var simple = new Talho.Rollcall.ADST.view.SimpleParameters({getBubbleTarget: this.getBubbleTarget});
    var advanced = new Talho.Rollcall.ADST.view.AdvancedParameters({getBubbleTarget: this.getBubbleTarget});
    var actionpanel = new Talho.Rollcall.ADST.view.ActionPanel({getBubbleTarget: this.getBubbleTarget});
    
    this.getSimple = function () { return simple; };
    this.getAdvanced = function () { return advanced; };
    this.getActions = function () { return actionpanel; };
    
    
    this.items = [simple, actionpanel];
    
    //TODO if store fails no auth and keel everytin up on controller    
    
    Ext.Ajax.request({
      url: '/rollcall/query_options',
      method: 'GET',
      scope: this,
      success: function (response) {
        var data = Ext.decode(response.responseText);
        this.getSimple().loadOptions(data);
        this.getAdvanced().loadOptions(data);
        this.doLayout();
      },
      failure: function (response) {
        this.fireEvent('notauthorized');
      }
    });        
    
    Talho.Rollcall.ADST.view.Parameters.superclass.initComponent.apply(this, config);        
  },
  
  getParams: function () {
    return (this.simple ? this.getSimple().getParams() : this.getAdvanced().getParams());
  },
    
  toggle: function () {
    this.simple = !this.simple
    this.items = [(this.simple ? this.getSimple() : this.getAdvanced()), this.getActions];
  },
  
  reset: function () {
    this.getAdvanced().reset();
  }
});