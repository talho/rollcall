//= require rollcall/alarm/view/alarmquery/New

Ext.namespace("Talho.Rollcall.alarm.view.alarmquery");

Talho.Rollcall.alarm.view.alarmquery.Edit = Ext.extend(Talho.Rollcall.alarm.view.alarmquery.New, { 
  layout: 'fit',
  
  _loadOptions: function (data) {
    this.school.bindStore(new Ext.data.JsonStore({fields: ['id', {name:'value', mapping:'display_name'}], data: data['schools']}));
    this.school_district.bindStore(new Ext.data.JsonStore({fields: ['id', {name:'value', mapping:'name'}], data: data['school_districts']}));    
    
    this.submit_button.setText("Submit Edits");
    this.setTitle('Edit Alarm Query');
    
    Ext.Ajax.request({
      url: 'rollcall/alarm_query/' + this.alarm_query_id,
      method: 'GET',
      scope: this,
      success: function (response) {
        var data = Ext.decode(response.responseText);
        this._applyValues(data.data);                   
      }
    });
  },
  
  _applyValues: function (data) {
    this.name.setValue(data.name);
    this.deviation.setValue(0, data.deviation, false);
    this.severity.setValue(0, data.severity, false);
    this.start_date.setValue(data.start_date);
    Ext.each(data.schools, function (record) {
      this.school.select(this.school.getStore().getById(record.id), true);
    }, this);
    Ext.each(data.school_districts, function (record) {
      this.school_district.select(this.school_district.getStore().getById(record.id), true);
    }, this);
  },
  
  _submitEvent: function () {
    this.addEvents('editalarmquery');
    this.enableBubble('editalarmquery');
    this.fireEvent('editalarmquery', this._getParams(), this.alarm_query_id);
  }
});