//= require_tree ./view

Ext.namespace('Talho.Rollcall.Graphing');

Talho.Rollcall.Graphing.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
    this.layout = new Talho.Rollcall.Graphing.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }
    
    this.layout.on({
      'reset': this._reset,
      'submitquery': this._submit,
      'activatebasic': this._activateBasic,
      'activateschool': this._activateSchool,
      'notauthorized': this._notAuthorized,
      'pagingparams': this._loadPagingParams,
      'afterrender': this._getOptions,
      'alarmshow': this._alarmShow,
      'getneighbors': this._getNeighbors,
      scope: this
    });

    Talho.Rollcall.Graphing.Controller.superclass.constructor.call(this);
  },
  
  _loadPagingParams: function(paging, params) {    
    var store = this.layout.results.getResultsStore();
    var lastOptions = store.lastOptions;
    lastOptions.params['start'] = params['start'];    
    
    store.load({params: lastOptions.params});
  },
  
  _getOptions: function () {
    var mask = this._mask();
    
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
        mask.hide();        
      },
      failure: function (response) {
        this.layout.fireEvent('notauthorized');        
      },
    });
  },
  
  _alarmShow: function () {
    
  },
  
  _reset: function () {
    Ext.each(this.layout.filters, function (f) {
      f.reset();
    });
  },
  
  _submit: function () {
    var params = this.layout.getParameters();
    this.layout.results.neighbor_mode = false;
    this.layout.results.paging_toolbar.show();
    var mask = this._mask();
    var callback = function () { mask.hide(); };
    this.layout.results.loadResultStore(params, callback);
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
  },
  
  _mask: function () {
    var mask = new Ext.LoadMask(this.layout.getEl(), {msg:"Loading..."});
    mask.show();
    
    return mask;
  },
  
  _getNeighbors: function (districts) {
    var mask = new Ext.LoadMask(this.layout.results.getEl(), {msg:"Please wait..."});
    mask.show();
    
    var params = {};
    params['school_districts[]'] = districts;
    
    var callback = function () { mask.hide(); }    
    this.layout.results.neighbor_mode = true;
    this.layout.results.paging_toolbar.hide();
    this.layout.results.loadResultStore(params, callback);
  },
});

Talho.ScriptManager.reg("Talho.Rollcall.Graphing", Talho.Rollcall.Graphing.Controller, function (config) {
  var cont = new Talho.Rollcall.Graphing.Controller(config);
  return cont.getPanel();
});