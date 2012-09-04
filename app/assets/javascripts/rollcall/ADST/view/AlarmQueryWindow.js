//

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.AlarmQueryWindow = Ext.extend(Ext.Window, {
  layout: 'fit',
  width: 300,
  height: 500,
  modal: true,
  initComponent: function () {
    var param_aray = this.state == 'new' ? [] : this.alarm_query.get('query_param_array');
    for(var k in this.query_params){
      param_aray.push({key: k, value: this.query_params[k]});
    }
    
    this.save_as_new_params = param_aray;
    
    var school_dropdown = false;
    for (var i = 0; i < this.save_as_new_params.length && this.state != 'new'; i++) {
      if (this.save_as_new_params[i].key == 'school') { 
        school_dropdown = this.save_as_new_params[i].value; 
      }
    }        
    
    this.school_dropdown = school_dropdown;        
    
    this.items = {
      xtype: 'form', itemId: 'form', labelWidth: 65, padding: '3', method: this.state == 'new' ? 'POST' : 'PUT',
      url: this.state == 'new' ? '/rollcall/alarm_query' : '/rollcall/alarm_query/' + this.alarm_query.get('id'),
      items: [
        {xtype: 'textfield', fieldLabel: 'Name', itemId: 'name', name: 'alarm_query[name]', value: this.state == 'new' ? 'Alarm query for ' + this.school_name : this.alarm_query.get('name'), anchor: '100%'},
        (this.school_dropdown ?
          new Talho.Rollcall.ux.ComboBox({
            labelStyle:   'margin: 10px 0px 0px 5px',
            fieldLabel:   'School',
            emptyText:    'Select School...',
            id:           'school_alarm',
            allowBlank:   true,
            width:        150,
            displayField: 'display_name',
            value: this.school_dropdown,
            editable:     false,
            store:        new Ext.data.JsonStore({fields: ['id', 'display_name'], url: 'rollcall/schools', 
            root: 'results', method: 'GET', autoLoad: true}),
            listeners:    {
              select: function(this_combo_box, data_record, index)
              {
                this.school_dropdown = data_record.get('display_name');                
              }, scope: this
            }
          }) : {xtype: 'spacer'}          
        ),
        {xtype: 'fieldset', title: 'Absentee Rate Deviation', items: [
          {xtype: 'container', fieldLabel: 'Min', items: [
            {xtype: 'numberfield', width: 30, style: 'float:left;', name: 'alarm_query[deviation_min]', value: this.state == 'new' ? 0 : this.alarm_query.get('deviation_min'), listeners: { keyup: this._changeSliderField }},
            {xtype: 'slider', tipText: this._tipTextDisplay, style: 'margin-left: 40px', submitValue: false, value: this.state == 'new' ? 0 : this.alarm_query.get('deviation_min'), listeners: { change: this._changeTextField }}
          ]},
          {xtype: 'container', fieldLabel: 'Max', items: [
            {xtype: 'numberfield', width: 30, style: 'float:left;', name: 'alarm_query[deviation_max]', value: this.state == 'new' ? 0 : this.alarm_query.get('deviation_max'), listeners: { keyup: this._changeSliderField }},
            {xtype: 'slider', tipText: this._tipTextDisplay, style: 'margin-left: 40px', submitValue: false, value: this.state == 'new' ? 0 : this.alarm_query.get('deviation_max'), listeners: { change: this._changeTextField }}
          ]}
        ]},
        {xtype: 'fieldset', title: 'Absentee Rate Severity', items: [
          {xtype: 'container', fieldLabel: 'Min', items: [
            {xtype: 'numberfield', width: 30, style: 'float:left;', name: 'alarm_query[severity_min]', value: this.state == 'new' ? 0 : this.alarm_query.get('severity_min'), listeners: { keyup: this._changeSliderField }},
            {xtype: 'slider', tipText: this._tipTextDisplay, style: 'margin-left: 40px', submitValue: false, value: this.state == 'new' ? 0 : this.alarm_query.get('severity_min'), listeners: { change: this._changeTextField }}
          ]},
          {xtype: 'container', fieldLabel: 'Max', items: [
            {xtype: 'numberfield', width: 30, style: 'float:left;', name: 'alarm_query[severity_max]', value: this.state == 'new' ? 0 : this.alarm_query.get('severity_max'), listeners: { keyup: this._changeSliderField }},
            {xtype: 'slider', tipText: this._tipTextDisplay, style: 'margin-left: 40px', submitValue: false, value: this.state == 'new' ? 0 : this.alarm_query.get('severity_max'), listeners: { change: this._changeTextField }}
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
    
    this.buttons = [];
    
    if (this.state != 'new') {
      this.buttons.push(
        {text: 'Save As New', scope: this, handler: function(){
          var params =  {};
          if (this.save_as_new_params) {
            var sub_params = new Object();
            var school_flag
            for (var i = 0; i < this.save_as_new_params.length; i++) {
              if (this.save_as_new_params[i].key == 'school') {
                sub_params[this.save_as_new_params[i].key] = this.school_dropdown;
                
              }
              else {            
                sub_params[this.save_as_new_params[i].key] = this.save_as_new_params[i].value;
              }
            }           
            
            params['alarm_query[query_params]'] = Ext.encode(sub_params);
          }
          
          this.getComponent('form').getForm().submit({
            params: params,
            scope: this,
            url: '/rollcall/alarm_query',
            method: 'post',
            success: function(form, action){
              this.fireEvent('savecomplete');
              this.close();
            },
            failure: function(form, action){
              Ext.Msg.alert('Save Error', 'Something went wrong with your save, please try again.');
            }
          })
        }
      });
    }
    
    this.buttons.push(
      {text: 'Save', scope: this, handler: function(){
        var params = {};
        if(this.query_params){
          params['alarm_query[query_params]'] = Ext.encode(this.query_params);
        }
        
        this.getComponent('form').getForm().submit({
          params: params,
          scope: this,
          success: function(form, action){
            this.fireEvent('savecomplete');
            this.close();
          },
          failure: function(form, action){
            Ext.Msg.alert('Save Error', 'Something went wrong with your save, please try again.');
          }
        })
      }
    });
    
    this.buttons.push({text: 'Cancel', scope: this, handler: function(){this.close();}});
    
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