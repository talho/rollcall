//= require_tree ./view

Ext.namespace('Talho.Rollcall.newGraphing');

Talho.Rollcall.newGraphing.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
    this.layout = new Talho.Rollcall.newGraphing.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }
    
    Ext.Ajax.request({
      url: '/rollcall/query_options',
      method: 'GET',
      scope: this,
      success: function (response) {
        var data = Ext.decode(response.responseText);
        Ext.each(this.layout.filters, function (f) {
          f.loadOptions(data);
        });
        this.layout.doLayout();
      },
      failure: function (response) {
        this.fireEvent('notauthorized');        
      }
    });
    
    Talho.Rollcall.newGraphing.Controller.superclass.constructor.call(this);
  }
});

Talho.ScriptManager.reg("Talho.Rollcall.newGraphing", Talho.Rollcall.newGraphing.Controller, function (config) {
  var cont = new Talho.Rollcall.newGraphing.Controller(config);
  return cont.getPanel();
});