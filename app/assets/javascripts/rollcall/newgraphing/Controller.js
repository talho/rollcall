//= require_tree ./view

Ext.namespace('Talho.Rollcall.newGraphing');

Talho.Rollcall.newGraphing.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
    this.layout = new Talho.Rollcall.newGraphing.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }
    
    this.layout.on({
      'reset': this._reset,
      'submitquery': this._submit,
      'activatebasic': this._activateBasic,
      'activateschool': this._activateSchool,
      'notauthorized': this._notAuthorized,
      scope: this
    });
    
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
  },
  
  _reset: function () {
    Ext.each(this.layout.filters, function (f) {
      f.reset();
    });
  },
  
  _submit: function () {
    //Show mask
    var params = this.layout.getParameters();
    this.layout.results.neighbor_mode = false;
    this.layout.results.loadResultStore(params);
    //hide mask
  },
  
  _activateBasic: function () {
    this.layout.school.reset();
  },
  
  _activateSchool: function () {
    this.layout.basic.reset();
  },
  
  _notAuthorized: function () {    
    Ext.Msg.alert('Access', 'You are not authorized to access this feature.  Please contact TX PHIN.', function() {
      this.layout.ownerCt.destroy();
    }, this);
  }
});

Talho.ScriptManager.reg("Talho.Rollcall.newGraphing", Talho.Rollcall.newGraphing.Controller, function (config) {
  var cont = new Talho.Rollcall.newGraphing.Controller(config);
  return cont.getPanel();
});