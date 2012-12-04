//= require ext_extensions/Portal
//= require rollcall/ux/ComboBox.js
//= require_tree ./view

Ext.namespace('Talho.Rollcall.Graphing');

Talho.Rollcall.Graphing.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
         
    this.layout = new Talho.Rollcall.Graphing.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }
    
    this.layout.addEvents('reset', 'submitquery', 'exportresult', 'notauthorized',
      'saveasalarm', 'createreport', 'showschoolprofile', 'showreportmessage', 'pagingparams');
    this.layout.on({
      'reset': this._resetForm,
      'submitquery': this._submitQuery,
      'createalarmquery': this.createAlarmFromGraph,
      'deletequery': this.deleteQuery,
      'editquery': this.showEditAlarmQueryWindow,
      'togglequery': this.toggleQueryState,
      'runquery': this.runQuery,
      'showreportmessage': this._showReportMessage,
      'notauthorized': this._notAuthorized,
      'exportresult': this._exportResultSet,
      'saveasalarm': this.createAlarmFromResultSet,
      'pagingparams': this._loadPagingParams,
      'getneighbors': this._getNeighbors,
      'showgraphingmask': this._showGraphingMask,
      'hidegraphingmask': this._hideGraphingMask,      
      scope: this
    });
    
    Talho.Rollcall.Graphing.Controller.superclass.constructor.apply(this, arguments)
  },
  
  _submitQuery: function (params) {
    var mask = new Ext.LoadMask(this.layout.graphing_panel.getEl(), {msg:"Please wait..."});
    mask.show();
    
    this.layout.on('resize', this._resizeResults, this);
    
    params['start'] = 0;
    params['limit'] = 6;
    this._showButtons();
    
    var callback = function () { mask.hide(); }
    this.layout.getResultsPanel().neighbor_mode = false;
    this.layout.paging_toolbar.show();
    this.layout.getResultsPanel().loadResultStore(params, callback);
  },
  
  _getNeighbors: function (districts) {
    var mask = new Ext.LoadMask(this.layout.graphing_panel.getEl(), {msg:"Please wait..."});
    mask.show();
    
    params['school_districts[]'] = districts;
    
    var callback = function () { mask.hide(); }
    this._hideButtons();
    this.layout.getResultsPanel().neighbor_mode = true;
    this.layout.paging_toolbar.hide();
    this.layout.getResultsPanel().loadResultStore(params, callback);
  },
  
  _loadPagingParams: function(paging, params) {    
    var store = this.layout.getResultsPanel().getResultsStore();
    var lastOptions = store.lastOptions;
    lastOptions.params['start'] = params['start'];    
    
    store.load({params: lastOptions.params});
  },
  
  _resetForm: function () {
    this.layout.getSearchForm().reset();
  },
  
  _notAuthorized: function () {    
    Ext.Msg.alert('Access', 'You are not authorized to access this feature.  Please contact TX PHIN.', function() {
      this.layout.ownerCt.destroy();
    }, this);
  },
  
  _exportResultSet: function () {
    var params = this.layout.getSearchForm().getParams();
    var param_string = '';
    
    for (key in params) {
      if (key != 'school_type[]' && key != 'zip[]') {
        param_string += key + '=' + params[key] + '&';
      }
    }
    
    Ext.MessageBox.show({
      title: 'Creating CSV Export File',
      msg:   'Your CSV file will be placed in your documents folders when the system '+
      'is done generating it. Please check your documents folder in a few minutes.',
      buttons: Ext.MessageBox.OK,
      icon:    Ext.MessageBox.INFO
    });
    
    Ext.Ajax.request({
      url:      '/rollcall/export',
      method:   'GET',
      scope:    this,
      params:   params,
      failure:  function(){}
    });
  },
  
  createAlarmFromGraph: function (id, name) {
    var params = this.layout.getSearchForm().getParams();
    if (params.school == undefined) {
      params.school = name;
    }
    if (params['school[]'] != undefined) {
      delete params['school[]'];
    }    
    
    this.showNewAlarmQueryWindow(id, name, params)
  },
  
  createAlarmFromResultSet: function () {
    var params = this.layout.getSearchForm().getParams();
    var name = 'Multiple Schools';
    
    this.showNewAlarmQueryWindow(null, name, params)
  },
  
  _showReportMessage: function (recipe, school_id) {
    Ext.Ajax.request({
      url:      '/rollcall/report',
      params:   {recipe_id: recipe, school_id: school_id},
      method:   'GET',
      callback: function(options, success, response)
      {
        var title = 'Generating Report';
        var msg   = 'Your report will be placed in the report portal when the system '+
                    'is done generating it. Please check the report portal in a few minutes.';
        Ext.MessageBox.show({
          title:   title,
          msg:     msg,
          buttons: Ext.MessageBox.OK,
          icon:    Ext.MessageBox.INFO
        });
      },
      failure: function(){ alert('Did not process'); }
    });
  },
  
  showNewAlarmQueryWindow: function(id, name, params){    
    // Create the new alarm window
    var win = new Talho.Rollcall.Graphing.view.AlarmQueryWindow({
      school_id: id, school_name: name, query_params: params, state: 'new', listeners: {
        scope: this,
        'savecomplete': function(){
          this.layout.alarm_queries.reload();
        }
      }
    });
    win.show();
  },
  
  showEditAlarmQueryWindow: function(id, alarm_query){
    // Get the params for the query
    var params = alarm_query.get('params');
    
    // Create the new alarm window
    var win = new Talho.Rollcall.Graphing.view.AlarmQueryWindow({
      alarm_query: alarm_query, state: 'edit', listeners: {
        scope: this,
        'savecomplete': function(){
          this.layout.alarm_queries.reload();
        }
      }
    });
    win.show();
  },
  
  toggleQueryState: function(id, alarm_query){
    Ext.Ajax.request({
      url: '/rollcall/alarm_query/' + id,
      method: 'PUT',
      params: {
        'alarm_query[alarm_set]': !alarm_query.get('alarm_set')
      },
      scope: this,
      callback: function(){
        if (!alarm_query.get('alarm_set')) {
          Ext.Ajax.request({
            url:      '/rollcall/alarms/',
            method:   'POST',
            params:   {alarm_query_id: id}
          });
        }  
        this.layout.alarm_queries.reload();              
      }
    });
  },
  
  deleteQuery: function(id){
    Ext.Msg.confirm("Delete Alarm Query", "Are you sure you would like to delete this alarm query? This action cannot be undone", function(btn){
      if(btn == "yes"){
        Ext.Ajax.request({
          url: '/rollcall/alarm_query/' + id,
          method: 'DELETE',
          scope: this,
          callback: function(options, success, response){
            this.layout.alarm_queries.reload();
          },
          failure: function(){
            Ext.Msg.alert("Error Saving", "There was a problem deleting your Alarm Query. Please try again.");
          }
        });
      }
    }, this);
  },
  
  runQuery: function(id, alarm_query){
    var param_aray = alarm_query.get('query_params');
    var params = Ext.decode(param_aray);
    var form = this.layout.getSearchForm();
    this.layout.getResultsPanel().loadResultStore(params);    
  },
  
  _resizeResults: function () {
    var mask = new Ext.LoadMask(this.layout.graphing_panel.getEl(), {msg:"Please wait..."});
    mask.show();
    
    var results = this.layout.getResultsPanel();
    var store = results.getResultsStore();
    results._loadGraphResults(store);
    mask.hide();
  },
  
  _showButtons: function () {
    Ext.each(this.layout.hidden_buttons, function (button) {
      if (button.hidden) { 
        button.show(); 
      }
    });
    this.layout.graphing_panel.getBottomToolbar().doLayout();
  },
  
  _hideButtons: function () {
    Ext.each(this.layout.hidden_buttons, function (button) {
      button.hide();
    });
    this.layout.graphing_panel.getBottomToolbar().doLayout();
  },
  
  _showGraphingMask: function () {
    var mask = new Ext.LoadMask(this.layout.graphing_panel.getEl(), {msg:"Please wait..."});
    this.layout.graphing_panel.container.mask = mask;
    mask.show();
  },
  
  _hideGraphingMask: function () {
    this.layout.graphing_panel.container.mask.hide();
  },
});

  
Talho.ScriptManager.reg("Talho.Rollcall.Graphing", Talho.Rollcall.Graphing.Controller, function (config) {
  var cont = new Talho.Rollcall.Graphing.Controller(config);
  return cont.getPanel();
});
