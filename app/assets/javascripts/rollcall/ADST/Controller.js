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
    
    this.layout.addEvents('reset', 'submitquery', 'export', 'saveasalarm', 'nextpage', 'showschoolprofile');
    this.layout.on({
      'reset': this._resetForm,
      'submitquery': this._submitQuery,
      'createalarmquery': this.showNewAlarmQueryWindow,
      'deletequery': this.deleteQuery,
      'editquery': this.showEditAlarmQueryWindow,
      'togglequery': this.toggleQueryState,
      'runquery': this.runQuery,
      'showschoolprofile': this._showSchoolProfile,
      scope: this
    });
    
    Talho.Rollcall.ADST.Controller.superclass.constructor.apply(this, arguments)
  },
    
  _submitQuery: function (params) {
    this.layout.getResultsPanel().loadResultStore(params);
  },
  
  _resetForm: function () {
    this.layout.getSearchForm().reset();
  },
  
  _exportResultSet: function () {
    
  },
  
  showNewAlarmQueryWindow: function(id, name){
    // Get the params for the query
    var params = this.result_panel.getSearchParams();
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
        this.layout.alarm_queries.reload();
      }
    });
  },
  
  deleteQuery: function(id){
    Ext.Msg.confirm("Delete Alarm Query", "Are you sure you would like to delete this alarm query? This action cannot be undone", function(btn){
      if(btn == "yes"){
        Ext.Ajax.request({
          url: '/rollcall/alarm_query/' + id + '.json',
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
    
  },
  
  _showSchoolProfile: function () {
    
  },
  
  _pinGraph: function () {
    
  },
});

  
Talho.ScriptManager.reg("Talho.Rollcall.ADST", Talho.Rollcall.ADST.Controller, function (config) {
  var cont = new Talho.Rollcall.ADST.Controller(config);
  return cont.getPanel();
});
