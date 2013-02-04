//= require_tree ./view
//= require ext_extensions/GMapPanel

Ext.namespace('Talho.Rollcall.alarm');

Talho.Rollcall.alarm.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
    this.layout = new Talho.Rollcall.alarm.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }
    
    this.layout.on({
      'createalarmquery': this._createAlarmQuery,
      'createnewalarmquery': this._createNewAlarmQuery,
      'editalarmquery': this._editAlarmQuery,
      'alarmgis': this._alarmGIS,
      'alarmshow': this._alarmShow,
      'alarmdelete': this._alarmDelete,
      'alarmignoretoggle': this._alarmIgnoreToggle,
      'querytoggle': this._queryToggle,
      'queryedit': this._queryEdit,
      'querydelete': this._queryDelete,
      'refresh': this._refresh,
      scope: this
    })
    
    Talho.Rollcall.alarm.Controller.superclass.constructor.call(this);
  },
  
  _createAlarmQuery: function () {
    this.newquery = new Talho.Rollcall.alarm.view.alarmquery.New({getBubbleTarget: this.layout.findBubble});
    this.newquery.show();
  },
  
  _createNewAlarmQuery: function (params) {
    Ext.Ajax.request({
      url: 'rollcall/alarm_query',
      method: 'POST',
      params: params,
      scope: this,
      success: function (response) {
        this.newquery.close();
        this.layout.queries.refresh();
        this.layout.center.refresh();
      },
      failure: function (response) {
        Ext.MessageBox.alert('Save Error', 'Please try again.');        
      }
    });
  },
  
  _editAlarmQuery: function (params, alarm_query_id) {
    Ext.Ajax.request({
      url: 'rollcall/alarm_query/' + alarm_query_id,
      method: 'PUT',
      params: params,
      scope: this,
      success: function (response) {
        this.editquery.close();
        this.layout.queries.refresh();
        this.layout.center.refresh();
      },
      failure: function (response) {
        Ext.MessageBox.alert('Save Error', 'Please try again.');        
      }
    });
  },
  
  _alarmGIS: function () {
    var win = new Talho.Rollcall.alarm.view.GIS({getBubbleTarget: this.layout.findBubble});
    win.show();
  },
  
  _alarmShow: function (alarm_id) {
    this.alarm_win = new Talho.Rollcall.alarm.view.alarm.Show({alarm_id: alarm_id, getBubbleTarget: this.layout.findBubble});
    this.alarm_win.show();
  },
  
  _alarmDelete: function (alarm_id) {
    Ext.Ajax.request({
      url: 'rollcall/alarms/' + alarm_id,
      method: 'DELETE',      
      scope: this,
      success: function (response) {        
        this.layout.center.refresh();
        this.alarm_win.close();
      },
      failure: function (response) {
        Ext.MessageBox.alert('Save Error', 'Please try again.');        
      }
    });
  },
  
  _alarmIgnoreToggle: function (alarm_id, ignore) {
    Ext.Ajax.request({
      url: 'rollcall/alarms/' + alarm_id,
      method: 'PUT',
      params: {"alarms[ignore_alarm]": !ignore},
      scope: this,
      success: function (response) {        
        this.layout.center.refresh();
        this.alarm_win.close();
      },
      failure: function (response) {
        Ext.MessageBox.alert('Save Error', 'Please try again.');        
      }
    });
  },
  
  _queryToggle: function (query_id, toggle) {
    Ext.Ajax.request({
      url: 'rollcall/alarm_query/toggle/' + query_id,
      method: 'POST',      
      scope: this,
      success: function (response) {
        this.layout.queries.refresh();
        this.layout.center.refresh();
        Ext.MessageBox.alert('Success', (toggle ? 'Turned off' : 'Turned on'));
      },
      failure: function (response) {
        Ext.MessageBox.alert('Save Error', 'Please try again.');        
      }
    });
  },
  
  _queryEdit: function (query_id) {
    this.editquery = new Talho.Rollcall.alarm.view.alarmquery.Edit({alarm_query_id: query_id, getBubbleTarget: this.layout.findBubble});
    this.editquery.show();
  },
  
  _queryDelete: function (query_id) {
    Ext.Ajax.request({
      url: 'rollcall/alarm_query/' + query_id,
      method: 'DELETE',
      scope: this,
      success: function (response) {
        this.layout.queries.refresh();
        this.layout.center.refresh();
        Ext.MessageBox.alert('Success', 'It has been deleted.'); 
      },
      failure: function (response) {
        Ext.MessageBox.alert('Delete Error', 'Please try again.');        
      }
    });
  },
  
  _refresh: function () {
    this.layout.queries.refresh();
    this.layout.center.refresh();
  }
});

Talho.ScriptManager.reg("Talho.Rollcall.Alarm", Talho.Rollcall.alarm.Controller, function (config) {
  var cont = new Talho.Rollcall.alarm.Controller(config);
  return cont.getPanel();
});