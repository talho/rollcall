//= require ext_extensions/Portal
//= require rollcall/ux/ComboBox.js
//= require rollcall/d3/d3.v2.min.js
//= require_tree ./view

Ext.namespace('Talho.Rollcall.ADST');

Talho.Rollcall.ADST.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function (config) {
 
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
      'nextpage': this._nextPage,
      'showschoolprofile': this._showSchoolProfile,
      scope: this
    });
    
    Talho.Rollcall.ADST.Controller.superclass.constructor.apply(this, config);
  },
  
  _submitQuery: function (params) {
    var form = this.layout.getSearchForm();
    var params = form.getParameters().getParams(form.getForm().getValues());
    form.getResults().loadResultStore(params);
    
    return true;
  },
  
  _grabListViewFormValues: function(params)
  {
    //TODO Evaluate if I need this
    // TODO: Push this down along with buildParams
    var list_fields  = ["school", "school_district", "school_type", "zip", "age", "grade", "symptoms"];
    for (var i=0; i < list_fields.length; i++) {
      var selected_records = Ext.getCmp(list_fields[i]+'_adv').getSelectedRecords();
      var vals = jQuery.map(selected_records, function(e,i){ return e.get('value'); });
      if (vals.length > 0) {
        params[list_fields[i]+'[]'] = vals;
      }
    }
  },
  
  _buildParams: function(form_values)
  {
    // TODO: We should be calling get params on each advanced or simple view. 
    // I don't have a problem with having them be separate forms and calling the currently active one to ask for its params
    var params = new Object;
    for (key in form_values){
      if (Ext.getCmp('advanced_query_select').isVisible()){
        if(key.indexOf('_adv') != -1 && form_values[key].indexOf('...') == -1)
          params[key.replace(/_adv/,'')] = form_values[key].replace(/\+/g, " ");
      }else{
        if(key.indexOf('_simple') != -1 && form_values[key].indexOf('...') == -1)
          params[key.replace(/_simple/,'')] = form_values[key].replace(/\+/g, " ");
      }
    }
    //TODO clean this up
    if (false && Ext.getCmp('advanced_query_select').isVisible()) params['type'] = 'adv'
    else params['type'] = 'simple'
    return params;
  },
  
  _resetForm: function () {
    this.layout.getSearchForm().reset();
  },
  
  _nextPage: function (toolbar, params)
  {
    var result_store = Ext.getCmp('ADSTResultPanel')._getResultsStore();       
    params['page'] = Math.floor(params.start / params.limit) + 1;
    return true;
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
    var params = Ext.decode(alarm_query.get('query_params'));
    var form = this.layout.getSearchForm();
    form.getResults().loadResultStore(params);    
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
