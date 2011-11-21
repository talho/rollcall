Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ux.AlarmQueryWindow = Ext.extend(Ext.Window, {
  constructor: function(config)
  {
    Ext.apply(this,{
      layout:       'fit',
      width:        300,
      //autoHeight:   true,
      //height:       200,
      modal:        true,
      constrain:    true,
	    renderTo:     config.render_to,
      closeAction:  'close',
      title:        config.alarm_query_title,
      plain:        true,
      result_panel: this,
      defaults: {
        listeners:{
          afterrender: function(this_obj){
            this_obj.doLayout();
          }
        }
      },
      items: [{
        xtype:      'form',
        id:         config.form_id,
        url:        config.form_url,
        border:     false,
        baseParams: {authenticity_token: config.auth_token, alarm_query_params: Ext.encode(config.query_params)},
        items:[{
          xtype:         'textfield',
          labelStyle:    'margin: 10px 0px 0px 5px',
          fieldLabel:    'Name',
          id:            'alarm_query_name',
          minLengthText: 'The minimum length for this field is 3',
          blankText:     "This field is required.",
          minLength:     3,
          allowBlank:    false,
          value:         config.alarm_query_title, 
          style:{
            marginTop:    '10px',
            marginBottom: '5px'
          }
        },((config.query_params.school == null) ? {xtype: 'spacer'} : new Talho.Rollcall.ux.ComboBox({
          labelStyle:   'margin: 10px 0px 0px 5px',
          fieldLabel:   'School Name',
          emptyText:    'Select School...',
          id:           'alarm_query_school',
          itemId:       'alarm_query_school',
          allowBlank:   true,
          width:        150,
          value:        config.query_params.school,
          mode:         'local',
          name:         'school',
          displayField: 'display_name',
          editable:     false,
          store:        new Ext.data.JsonStore({fields: ['id', 'display_name'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('schools')}),
          listeners:    {
            select: function(this_combo_box, data_record, index)
            {
              config.query_params['school']               = data_record.get('display_name');
              this_combo_box.ownerCt.getForm().baseParams = {alarm_query_params: Ext.encode(config.query_params)};
            }
          }
        })),{
          xtype: 'fieldset',
          title: 'Absentee Rate Deviation',
          style: {
            marginLeft:  '5px',
            marginRight: '5px'
          },
          buttonAlign: 'left',
          defaults: {
            xtype:      'container',
            labelStyle: 'width:auto;'
          },
          items: [{
            fieldLabel: 'Min',
            items:[{
              xtype: 'numberfield',
              width: 32,
              cls:   'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px',
                zIndex: '300'
              },
              listeners: {
                keyup: this.changeSliderField
              },
              enableKeyEvents: true,
              id: 'min_deviation'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                change: this.changeTextField
              },
              tipText: this.showTipText,
              id:      'deviation_min',
              cls:     'ux-layout-auto-float-item',
              value:   config.deviation_min
            }]
          },{
            fieldLabel: 'Max',
            items:[{
              xtype: 'numberfield',
              width: 32,
              cls:   'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              listeners: {
                keyup: this.changeSliderField
              },
              enableKeyEvents: true,
              id: 'max_deviation'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                change: this.changeTextField
              },
              tipText: this.showTipText,
              id:      'deviation_max',
              cls:     'ux-layout-auto-float-item',
              value:   config.deviation_max
            }]
          }],
          fbar: {
            xtype: 'toolbar',
            items: ['->', {
              text:    'Max All',
              handler: this.maxFields
            }]
          }
        },{
          xtype:      'fieldset',
          autoHeight: true,
          title:      'Absentee Rate Severity',
          style:{
            marginLeft:  '5px',
            marginRight: '5px'
          },
          buttonAlign: 'left',
          defaults: {
            xtype:  'container',
            labelStyle: 'width:auto;',
            layout: 'anchor'
          },
          items: [{
            fieldLabel: 'Min',
            items:[{
              xtype: 'numberfield',
              width: 32,
              cls:   'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              listeners: {
                keyup: this.changeSliderField
              },
              enableKeyEvents: true,
              id: 'min_severity'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                change: this.changeTextField
              },
              tipText: this.showTipText,
              id:      'severity_min',
              value:   config.severity_min,
              cls:     'ux-layout-auto-float-item'
            }]
          },{
            fieldLabel: 'Max',
            items:[{
              xtype: 'numberfield',
              width: 32,
              cls:   'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              listeners: {
                keyup: this.changeSliderField
              },
              enableKeyEvents: true,
              id: 'max_severity'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                change: this.changeTextField
              },
              tipText: this.showTipText,
              id:      'severity_max',
              value:   config.severity_max,
              cls:     'ux-layout-auto-float-item'
            }]
          }],
          fbar: {
            xtype: 'toolbar',
            items: ['->', {
              text:    'Max All',
              handler: this.maxFields
            }]
          }
        },{
          xtype:      'fieldset',
          autoWidth:  true,
          autoHeight: true,
          title:      'Parameters',
          style:{
            marginLeft:  '5px',
            marginRight: '5px'
          },
          collapsible: false,
          items: [{
            xtype:               'listview',
            store:               config.stored_params,
            multiSelect:         true,
            reserveScrollOffset: true,
            columns: [{
                header:    'Field Name',
                width:     .65,
                dataIndex: 'field'
            },{
                header:    'Value Set',
                width:     .35,
                dataIndex: 'value'
            }]
          }]
        }]
      }],
      buttonAlign: 'right',
      buttons: [config.buttons],
      listeners:{
        afterrender: function(this_window){
          this_window.doLayout();
        }
      }
    });
    Talho.Rollcall.ux.AlarmQueryWindow.superclass.constructor.call(this);
  },
  changeTextField: function(obj, new_number, old_number)
  {
    obj.ownerCt.findByType('textfield')[0].setValue(new_number)
  },
  changeSliderField: function(this_field, event_obj)
  {
    this_field.nextSibling().setValue(this_field.getValue());
  },
  maxFields: function(buttonEl, eventObj)
  {
    sliders = buttonEl.ownerCt.ownerCt.findByType("sliderfield");
    for(key in sliders){
      try{
        sliders[key].setValue(100);
      }catch(e){}
    }
  },
  showTipText: function(thumb)
  {
    return String(thumb.value) + '%';
  }
});
