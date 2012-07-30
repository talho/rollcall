//= require ext_extensions/Portal
//= require rollcall/ux/ComboBox.js
//= require rollcall/d3/d3.v2.min.js
//= require rollcall/ADST/view/Layout

Ext.namespace('Talho.Rollcall.ADST');

Talho.Rollcall.ADST.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function (config) {
 
    this.layout = new Talho.Rollcall.ADST.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }
    
    this.layout.addEvents('reset', 'submitquery', 'export', 'saveasalarm');
    this.layout.on({
      'reset': this._resetForm,
      'submitquery': this._submitQuery,
      scope: this
    });
    
    Talho.Rollcall.ADST.Controller.superclass.constructor.apply(this, config);
  },
  
  _submitQuery: function () {
    var form_panel = Ext.getCmp('ADSTFormPanel');
    var form_values = form_panel.getForm().getValues();
    var result_store = Ext.getCmp('ADSTResultPanel')._getResultStore();    
    var params = this._buildParams(form_values);
    result_store.baseParms = {};
    this._grabListViewFormValues(params);
        
    for(key in params){
      if(params[key].indexOf('...') == -1 && key.indexOf("[]") == -1 && key != 'authenticity_token'){
        result_store.setBaseParam(key, params[key].replace(/\+/g, " "));
      }else if(params[key].indexOf('...') == -1){
        result_store.setBaseParam(key, params[key]);
      }
    }
    
    result_store.load();
    return true;
  },
  
  _grabListViewFormValues: function(params)
  {
    var list_fields  = ["school", "school_district", "school_type", "zip", "age", "grade", "symptoms"];
    for (var i=0; i < list_fields.length; i++) {
      var selected_records = Ext.getCmp(list_fields[i]+'_adv').getSelectedRecords();
      var vals             = jQuery.map(selected_records, function(e,i){ return e.get('value'); });
      if (vals.length > 0) params[list_fields[i]+'[]'] = vals;
    }
  },
  
  _buildParams: function(form_values)
  {
    var params = new Object;
    params['authenticity_token'] = FORM_AUTH_TOKEN;
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
    Ext.getCmp('ADSTFormPanel').getForm().reset();
    Ext.getCmp('school_adv').clearSelections();
    Ext.getCmp('school_type_adv').clearSelections();
    Ext.getCmp('zip_adv').clearSelections();
    Ext.getCmp('age_adv').clearSelections();
    Ext.getCmp('grade_adv').clearSelections();
    Ext.getCmp('symptoms_adv').clearSelections();
    Ext.getCmp('school_district_adv').clearSelections();
  },
  
  _exportResultSet: function () {
    
  },
  
  _saveQueryAsAlarm: function () {
    
  }  
  
});


Talho.ScriptManager.reg("Talho.Rollcall.ADST", Talho.Rollcall.ADST.Controller, function (config) {
  var cont = new Talho.Rollcall.ADST.Controller(config);
  return cont.getPanel();
});
