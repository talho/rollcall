//= require ext_extensions/Portal
//= require rollcall/ux/ComboBox.js
//= require rollcall/d3/d3.v2.min.js
//= require_tree ./view

Ext.namespace('Talho.Rollcall.ADST');

Talho.Rollcall.ADST.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
         
    this.layout = new Talho.Rollcall.ADST.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }
    
    this.layout.addEvents('reset', 'submitquery', 'exportresult', 'notauthorized',
      'saveasalarm', 'createreport', 'showschoolprofile', 'showreportmessage');
    this.layout.on({
      'reset': this._resetForm,
      'submitquery': this._submitQuery,
      'createalarmquery': this.showNewAlarmQueryWindow,
      'deletequery': this.deleteQuery,
      'editquery': this.showEditAlarmQueryWindow,
      'togglequery': this.toggleQueryState,
      'runquery': this.runQuery,
      'showreportmessage': this._showReportMessage,
      'notauthorized': this._notAuthorized,
      'exportresult': this._exportResultSet,
      scope: this
    });
    
    Talho.Rollcall.ADST.Controller.superclass.constructor.apply(this, arguments)
  },
  
  _submitQuery: function (params) {
    var mask = new Ext.LoadMask(this.layout.adst_panel.getEl(), {msg:"Please wait..."});
    mask.show();
    
    var callback = function () { mask.hide(); }
    this.layout.getResultsPanel().loadResultStore(params, callback);
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
      url:      '/rollcall/export?' + param_string,
      method:   'GET',
      scope:    this,
      failure: function(){}
    });
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
  
  showNewAlarmQueryWindow: function(id, name){
    // Get the params for the query
    var params = this.layout.getSearchForm().getParams();
    params['school[]'] = [name];
    
    // Create the new alarm window
    var win = new Talho.Rollcall.ADST.view.AlarmQueryWindow({
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
    var win = new Talho.Rollcall.ADST.view.AlarmQueryWindow({
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
    var params = Ext.decode(alarm_query.get('query_params'));
    var form = this.layout.getSearchForm();
    this.layout.getResultsPanel().loadResultStore(params);    
  },
});

  
Talho.ScriptManager.reg("Talho.Rollcall.ADST", Talho.Rollcall.ADST.Controller, function (config) {
  var cont = new Talho.Rollcall.ADST.Controller(config);
  return cont.getPanel();
});
