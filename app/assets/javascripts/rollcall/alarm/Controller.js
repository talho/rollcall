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
      'alarmgis': this._alarmGIS,
      'alarmshow': this._alarmShow,
      'querytoggle': this._queryToggle,
      'queryedit': this._queryEdit,
      'querydelete': this._queryDelete,
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
        this.layout.index.refresh();
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
    var win = new Talho.Rollcall.alarm.view.alarm.Show({alarm_id: alarm_id});
    win.show();
  },
  
  _queryToggle: function (query_id, toggle) {
    Ext.Ajax.request({
      url: 'rollcall/alarm_query/toggle/' + query_id,
      method: 'POST',
      params: params,
      scope: this,
      success: function (response) {
        this.layout.queries.refresh();
        this.layout.center.refresh();
        Ext.MessageBox.alert('Success', (toggle ? 'Turned on' : 'Turned off'));
      },
      failure: function (response) {
        Ext.MessageBox.alert('Save Error', 'Please try again.');        
      }
    });
  },
  
  _queryEdit: function (query_id) {
    this.editquery = new Talho.Rollcall.alarm.view.alarmquery.Edit({getBubbleTarget: this.layout.findBubble});
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
  }
});

Talho.ScriptManager.reg("Talho.Rollcall.Alarm", Talho.Rollcall.alarm.Controller, function (config) {
  var cont = new Talho.Rollcall.alarm.Controller(config);
  return cont.getPanel();
});