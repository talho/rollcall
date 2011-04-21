Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.AdvancedADSTContainer = Ext.extend(Ext.Container, {
  constructor: function(config)
  {
    Ext.applyIf(config, {
      title:   "Advanced Query Select",
      id:      "advanced_query_select",
      itemId:  "advanced_query_select",
      hidden:  true,
      layout:  'auto',
      items:   [{
        xtype:   'container',
        layout:  'hbox',
        height:  350,
        padding: '0 5',
        items:   [{
          xtype: 'spacer',
          width: 5
        },{
          xtype:  'fieldset',
          layout: 'hbox',
          width:  335,
          title:  'School Query',
          items:  [{
            xtype:    'container',
            layout:   'vbox',
            width:    150,
            height:   300,
            defaults: {width:150},
            items:    [{
              xtype: 'label',
              html:  'School Type:'
            },{
              xtype:        'listview',
              id:           'school_type_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value'}],
              hideHeaders:  true,
              height:       100,
              store:        new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.school_type})
            },{
              xtype:  'spacer',
              height: 10
            },{
              xtype: 'label',
              html:  'Zipcode:'
            },{
              xtype:        'listview',
              id:           'zip_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value'}],
              hideHeaders:  true,
              height:       100,
              store:        new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.zipcode})
            }]
          },{
            xtype: 'spacer',
            width: 10
          },{
            xtype:    'container',
            layout:   'vbox',
            width:    150,
            height:   300,
            defaults: {width:150},
            items: [{
              xtype: 'label',
              html:  'School Name:'
            },{
              xtype:        'listview',
              id:           'school_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value'}],
              hideHeaders:  true,
              height:       229,
              store:        new Ext.data.JsonStore({fields: ['id', {name:'value', mapping:'display_name'}], data: config.options.schools})
            }]
          }]
        },{
          xtype: 'spacer',
          width: 5
        },{
          xtype:  'fieldset',
          layout: 'hbox',
          width:  385,
          title:  'Data Filter',
          items:  [{
            xtype:    'container',
            layout:   'vbox',
            width:    150,
            height:   300,
            defaults: {width:150},
            items:    [{
              xtype: 'label',
              html:  'Age:'
            },{
              xtype:        'listview',
              id:           'age_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value'}],
              hideHeaders:  true,
              height:       100,
              store:        new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.age})
            },{
              xtype: 'spacer',
              height: 10
            },{
              xtype: 'label',
              html:  'Grade:'
            },{
              xtype:        'listview',
              id:           'grade_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value'}],
              hideHeaders:  true,
              height:       100,
              store:        new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.grade})
            }]
          },{
            xtype: 'spacer',
            width: 10
          },{
            xtype:    'container',
            layout:   'vbox',
            width:    200,
            height:   300,
            defaults: {width:200},
            items:    [{
              xtype: 'label',
              html:  'Symptoms:'
            },{
              xtype:        'listview',
              id:           'symptoms_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'name', width: 0.70}, {dataIndex: 'value'}],
              hideHeaders:  true,
              height:       179,
              store:        new Ext.data.JsonStore({fields: ['id', 'name', {name:'value', mapping:'icd9_code'}], data: config.options.symptoms})
            },{
              xtype: 'spacer',
              height: 10
            },{
              xtype: 'label',
              html:  'Gender:'
            },new Talho.Rollcall.ux.ComboBox({
              id:         'gender_adv',
              fieldLabel: 'Gender',
              editable:   false,
              emptyText:  'Select Gender...',
              store:      new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.gender})
            })]
          }]
        },{
          xtype: 'spacer',
          width: 5
        },{
          xtype:  'fieldset',
          layout: 'hbox',
          width:  335,
          title:  'Data Types/Date Range',
          items:  [{
            xtype:    'container',
            layout:   'vbox',
            width:    150,
            height:   300,
            defaults: {width:150},
            items:    [{
              xtype: 'label',
              html:  'Absenteeism:'
            },new Talho.Rollcall.ux.ComboBox({
              id:         'absent_adv',
              fieldLabel: 'Absenteeism',
              editable:   false,
              value:      'Gross',
              store:      new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.absenteeism})
            }),{
              xtype: 'spacer',
              height: 10
            },{
              xtype: 'label',
              html:  'Start Date:'
            },{
              xtype:        'datefield',
              fieldLabel:   'Start Date',
              name:         'startdt_adv',
              id:           'startdt_adv',
              endDateField: 'enddt_adv',
              emptyText:    'Select Start Date...',
              allowBlank:   true,
              ctCls:        'ux-combo-box-cls'
            }]
          },{
            xtype: 'spacer',
            width: 10
          },{
            xtype:    'container',
            layout:   'vbox',
            width:    150,
            height:   300,
            defaults: {width:150},
            items:    [{
              xtype: 'label',
              html:  'Data Function:'
            },new Talho.Rollcall.ux.ComboBox({
              id:       'data_func_adv',
              editable: false,
              value:    'Raw',
              store:    new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.data_functions_adv})
            }),{
              xtype:  'spacer',
              height: 10
            },{
              xtype: 'label',
              html:  'End Date:'
            },{
              xtype:          'datefield',
              fieldLabel:     'End Date',
              name:           'enddt_adv',
              id:             'enddt_adv',
              startDateField: 'startdt_adv',
              emptyText:      'Select End Date...',
              allowBlank:     true,
              ctCls:          'ux-combo-box-cls'
            }]
          }]
        }]
      },{
        xtype:     'checkbox',
        id:        'enrolled_base_line_adv',
        cls:       'base-line-check',
        boxLabel:  'Display Total Enrolled Base Line',
        hideLabel: true
      },{
        cls:     'clear',
        xtype:   'button',
        text:    'Switch to Simple View >>',
        style:   {margin: '6px 0px 5px 5px'},
        scope:   this,
        handler: function(buttonEl, eventObj){
          this.hide();
          Ext.getCmp('simple_query_select').show();
        }
      }]
    });
    Talho.Rollcall.AdvancedADSTContainer.superclass.constructor.call(this, config);
  }
});