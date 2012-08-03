//

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.AlarmQueryWindow = Ext.extend(Ext.Window, {
  layout: 'fit',
  width: 300,
  height: 500,
  modal: true,
  initComponent: function () {
    var param_aray = []
    for(var k in this.query_params){
      param_aray.push({key: k, value: this.query_params[k]});
    }
    
    this.items = {
      xtype: 'form', itemId: 'form', labelWidth: 65, padding: '3', method: this.state == 'new' ? 'POST' : 'PUT',
      url: this.state == 'new' ? '/rollcall/alarm_query' : '/rollcall/alarm_query/' + this.alarm_query_id,
      items: [
        {xtype: 'textfield', fieldLabel: 'Name', itemId: 'name', name: 'alarm_query[name]', value: this.state == 'new' ? 'Alarm query for ' + this.school_name : '', anchor: '100%'},
        {xtype: 'fieldset', title: 'Absentee Rate Deviation', items: [
          {xtype: 'container', fieldLabel: 'Min', items: [
            {xtype: 'numberfield', width: 30, style: 'float:left;', name: 'alarm_query[deviation_min]', value: 0, listeners: { keyup: this._changeSliderField }},
            {xtype: 'slider', tipText: this._tipTextDisplay, style: 'margin-left: 40px', submitValue: false, value: 0, listeners: { change: this._changeTextField }}
          ]},
          {xtype: 'container', fieldLabel: 'Max', items: [
            {xtype: 'numberfield', width: 30, style: 'float:left;', name: 'alarm_query[deviation_max]', value: 0, listeners: { keyup: this._changeSliderField }},
            {xtype: 'slider', tipText: this._tipTextDisplay, style: 'margin-left: 40px', submitValue: false, value: 0, listeners: { change: this._changeTextField }}
          ]}
        ]},
        {xtype: 'fieldset', title: 'Absentee Rate Severity', items: [
          {xtype: 'container', fieldLabel: 'Min', items: [
            {xtype: 'numberfield', width: 30, style: 'float:left;', name: 'alarm_query[severity_min]', value: 0, listeners: { keyup: this._changeSliderField }},
            {xtype: 'slider', tipText: this._tipTextDisplay, style: 'margin-left: 40px', submitValue: false, value: 0, listeners: { change: this._changeTextField }}
          ]},
          {xtype: 'container', fieldLabel: 'Max', items: [
            {xtype: 'numberfield', width: 30, style: 'float:left;', name: 'alarm_query[severity_max]', value: 0, listeners: { keyup: this._changeSliderField }},
            {xtype: 'slider', tipText: this._tipTextDisplay, style: 'margin-left: 40px', submitValue: false, value: 0, listeners: { change: this._changeTextField }}
          ]}
        ]},
        {xtype: 'fieldset', title: 'Parameters', items: {
          xtype: 'listview', height: 174, autoScroll: true, store: new Ext.data.JsonStore({data: param_aray, fields: ['key', 'value'], autoDestroy: true}), columns: [
            { header: 'Field Name', width: .65, dataIndex: 'key' },
            { header: 'Value', width: .35, dataIndex: 'value'}
          ]
        }}
      ]
    };
    
    this.title = this.state == 'new' ? 'New Alarm Query' : 'Edit Alarm Query';
    
    this.buttons = [
      {text: 'Save', scope: this, handler: function(){
        this.getComponent('form').getForm().submit({
          params: {'alarm_query[query_params]': Ext.encode(this.query_params)},
          scope: this,
          success: function(form, action){
            this.fireEvent('savecomplete');
            this.close();
          },
          failure: function(form, action){
            Ext.Msg.alert('Save Error', 'Something went wrong with your save, please try again.');
          }
        })
      }},
      {text: 'Cancel', scope: this, handler: function(){this.close();}}
    ]
    
    Talho.Rollcall.ADST.view.AlarmQueryWindow.superclass.initComponent.apply(this, arguments);
  },
  
  _changeTextField: function(obj, new_number, old_number)
  {
    obj.ownerCt.findByType('textfield')[0].setValue(new_number)
  },
  
  _changeSliderField: function(this_field, event_obj)
  {
    this_field.nextSibling().setValue(this_field.getValue());
  },
  
  _tipTextDisplay: function(thumb)
  {
    return thumb.value + '%';
  }
});