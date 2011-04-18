Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.AdvancedADSTContainer = Ext.extend(Ext.Container, {
  constructor: function(config)
  {
    Ext.applyIf(config, {
      title:   "Advanced Query Select",
      id:      "advanced_query_select",
      itemId:  "advanced_query_select",
      layout: 'form',
      items: [
        {xtype: 'container', layout: 'hbox', width: 750, height: 350, padding: '0 5', items: [
          {xtype: 'panel', layout: 'hbox', padding: 5, width: 330, defaults: {margins: '0 5'}, title: 'School Query', items: [
            {xtype: 'container', layout: 'vbox', width: 150, height: 300, defaults: {width:150}, items: [
              {xtype: 'label', html: 'School Type:'},
              new Ext.ListView({id: 'school_type_adv', multiSelect: true,
                cls: 'ux-query-form', columns: [{dataIndex: 'value'}], hideHeaders: true,
                store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.school_type})}),
              {xtype: 'spacer', height: 10},
              {xtype: 'label', html: 'Zipcode:'},
              new Ext.ListView({id: 'zip_adv', flex: 1, multiSelect: true,
                cls: 'ux-query-form', columns: [{dataIndex: 'value'}], hideHeaders: true,
                store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.zipcode})})
            ]},
            {xtype: 'container', layout: 'vbox', width: 150, height: 300, defaults: {width:150}, items: [
              {xtype: 'label', html: 'School Name:'},
              new Ext.ListView({id: 'school_adv', flex: 1, multiSelect: true,
                cls: 'ux-query-form', columns: [{dataIndex: 'value'}], hideHeaders: true,
                store: new Ext.data.JsonStore({fields: ['id', {name:'value', mapping:'display_name'}], data: config.options.schools})})
            ]}
          ]},
          {xtype: 'spacer', width: 5},
          {xtype: 'panel', layout: 'hbox', padding: 5, width: 380, defaults: {margins: '0 5'}, title: 'With Data Filter', items: [
            {xtype: 'container', layout: 'vbox', width: 150, height: 300, defaults: {width:150}, items: [
              {xtype: 'label', html: 'Absenteeism:'},
              new Talho.Rollcall.ux.ComboBox({id: 'absent_adv', fieldLabel: 'Absenteeism', editable: false, value: 'Gross',
                store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.absenteeism})}),
              {xtype: 'spacer', height: 10},
              {xtype: 'label', html: 'Age:'},
              new Ext.ListView({id: 'age_adv', flex: 1, multiSelect: true,
                cls: 'ux-query-form', columns: [{dataIndex: 'value'}], hideHeaders: true,
                store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.age})}),
              {xtype: 'spacer', height: 10},
              {xtype: 'label', html: 'Grade:'},
              new Ext.ListView({id: 'grade_adv', flex: 1, multiSelect: true,
                cls: 'ux-query-form', columns: [{dataIndex: 'value'}], hideHeaders: true,
                store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.grade})}),
              {xtype: 'spacer', height: 10},
              {xtype: 'label', html: 'Gender:'},
              new Talho.Rollcall.ux.ComboBox({id: 'gender_adv', fieldLabel: 'Gender', editable: false, emptyText: 'Select Gender...',
                store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.gender})})
            ]},
            {xtype: 'container', layout: 'vbox', width: 200, height: 300, defaults: {width:200}, items: [
              {xtype: 'label', html: 'Data Function:'},
              new Talho.Rollcall.ux.ComboBox({id: 'data_func_adv', editable: false, value: 'Raw',
                store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.data_functions_adv})}),
              {xtype: 'spacer', height: 10},
              {xtype: 'label', html: 'Symptoms:'},
              new Ext.ListView({id: 'symptoms_adv', multiSelect: true, flex: 1,
                /*valueField: 'icd9_code', hiddenName: 'icd9_code_adv'*/
                cls: 'ux-query-form', columns: [{dataIndex: 'name', width: 0.75}, {dataIndex: 'icd9_code'}], hideHeaders: true,
                store: new Ext.data.JsonStore({fields: ['id', 'name', 'icd9_code'], data: config.options.symptoms})}),
              {xtype: 'spacer', height: 10},
              {xtype: 'label', html: 'Date Range:'},
              {xtype: 'datefield', fieldLabel: 'Start Date', name: 'startdt_adv', id: 'startdt_adv',
                endDateField: 'enddt_adv', emptyText: 'Select Start Date...', allowBlank: true, ctCls: 'ux-combo-box-cls'},
              {xtype: 'datefield', fieldLabel: 'End Date', name: 'enddt_adv', id: 'enddt_adv',
                startDateField: 'startdt_adv', emptyText: 'Select End Date...', allowBlank: true, ctCls: 'ux-combo-box-cls'}
            ]}
          ]}
        ]},
        {xtype: 'spacer', height: 30},
        {
          cls: 'base-line-check',
          items:{
            xtype: 'checkbox',
            id: 'enrolled_base_line_adv',
            boxLabel: "Display Total Enrolled Base Line"
          }
        }
      ]
    });
    Talho.Rollcall.AdvancedADSTContainer.superclass.constructor.call(this, config);
  }
});
