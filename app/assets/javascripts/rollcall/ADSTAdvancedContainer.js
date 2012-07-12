Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ADSTAdvancedContainer = Ext.extend(Ext.Container, {
  /*
  ADSTAdvancedContainer construct, config object contains data used to populate drop downs, lists.  Constructor gets
  called from ADST.js, initformComponent method
  @param config object containing data to populate form with
   */
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
        height:  275,
        padding: '0 5',
        items:   [{
          xtype: 'spacer',
          width: 5
        },{
          xtype:  'fieldset',
          layout: 'hbox',
          width:  262,
          //TODO: Let's conditionalize this for School District & School
          title:  'School Filter',
          items:  [{
            xtype:    'container',
            layout:   'vbox',
            width:    100,
            height:   230,
            defaults: {width:100},
            items:    [{
              xtype: 'label',
              html:  'School Type:'
            },{
              xtype:        'listview',
              id:           'school_type_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value', cls:'school-type-list-item'}],
              hideHeaders:  true,
              height:       90,
              store:        new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.school_type})
            },{
              xtype:  'spacer',
              height: 5
            },{
              xtype: 'label',
              html:  'Zipcode:'
            },{
              xtype:        'listview',
              id:           'zip_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value', cls:'zipcode-list-item'}],
              hideHeaders:  true,
              height:       90,
              store:        new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.zipcode})
            }]
          },{
            xtype: 'spacer',
            width: 5
          },{
            xtype:    'container',
            layout:   'vbox',
            width:    135,
            height:   230,
            defaults: {width:135},
            items: [{
              xtype: 'label',
              html:  'School District:'
            },{
              xtype:        'listview',
              id:           'school_district_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value', cls:'school-district-list-item'}],
              hideHeaders:  true,
              height:       90,
              store:        new Ext.data.JsonStore({fields: ['id', {name:'value', mapping:'name'}], data: config.options.school_districts})
            },{
              xtype:  'spacer',
              height: 5
            },{
              xtype: 'label',
              html:  'School Name:'
            },{
              xtype:        'listview',
              id:           'school_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value', cls:'school-name-list-item'}],
              hideHeaders:  true,
              height:       90,
              store:        new Ext.data.JsonStore({fields: ['id', {name:'value', mapping:'display_name'}], data: config.options.schools})
            }]
          }]
        },{
          xtype: 'spacer',
          width: 5
        },{
          xtype:  'fieldset',
          layout: 'hbox',
          width:  328,
          title:  'ILI Data Filter',
          items:  [{
            xtype:    'container',
            layout:   'vbox',
            width:    120,
            height:   230,
            defaults: {width:120},
            items:    [{
              xtype: 'label',
              html:  'Age:'
            },{
              xtype:        'listview',
              id:           'age_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value', cls: 'age-list-item'}],
              hideHeaders:  true,
              height:       90,
              store:        new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.age})
            },{
              xtype: 'spacer',
              height: 5
            },{
              xtype: 'label',
              html:  'Grade:'
            },{
              xtype:        'listview',
              id:           'grade_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'value', cls: 'grade-list-item'}],
              hideHeaders:  true,
              height:       90,
              store:        new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.grade})
            }]
          },{
            xtype: 'spacer',
            width: 5
          },{
            xtype:    'container',
            layout:   'vbox',
            width:    180,
            height:   230,
            defaults: {width:180},
            items:    [{
              xtype: 'label',
              html:  'Symptoms:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ICD-9 Code'
            },{
              xtype:        'listview',
              id:           'symptoms_adv',
              multiSelect:  true,
              simpleSelect: true,
              cls:          'ux-query-form',
              columns:      [{dataIndex: 'name', width: 0.70, cls:'symptom-list-item'}, {dataIndex: 'value'}],
              hideHeaders:  true,
              height:       160,
              store:        new Ext.data.JsonStore({fields: ['id', 'name', {name:'value', mapping:'icd9_code'}], data: config.options.symptoms})
            },{
              xtype: 'spacer',
              height: 5
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
          width:  252,
          title:  'Data Types/Date Range',
          items:  [{
            xtype:    'container',
            layout:   'vbox',
            width:    110,
            height:   230,
            defaults: {width:110},
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
              fieldLabel:   'Start Date Adv',
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
            width:    110,
            height:   230,
            defaults: {width:110},
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
              fieldLabel:     'End Date Adv',
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
        xtype:    'checkbox',
        id:       'return_individual_school_adv',
        cls:      'line-check',
        checked:  true,
        boxLabel: "Return Individual School Results"
      },{
        cls:     'clear',
        xtype:   'button',
        text:    'Switch to Simple View >>',
        style:   {margin: '6px 0px 5px 5px'},
        scope:   this,
        handler: function(buttonEl, eventObj){
          this.hide();
          Ext.getCmp('rollcall_adst')._resetForm();
          Ext.getCmp('simple_query_select').show();
        }
      }]
    });

    Talho.Rollcall.ADSTAdvancedContainer.superclass.constructor.call(this, config);
  }
});