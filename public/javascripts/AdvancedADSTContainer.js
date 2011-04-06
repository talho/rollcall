Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.AdvancedADSTContainer = Ext.extend(Ext.Container, {
  constructor: function(config)
  {
    Ext.applyIf(config, {
      title:       "Advanced Query Select",
      id:          "advanced_query_select",
      itemId:      "advanced_query_select",
      hidden:      true,
      //padding:     '0 0 5 5',
      layout:     'auto',
      defaults:{
        xtype: 'container',
        layout: 'form',
        cls: 'ux-layout-auto-float-item',
        style: {
          width:    '200px',
          minWidth: '200px'
        },
        defaults:{
          width: 200
        }
      },
      items: [{
        items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Absenteeism',
            emptyText:  'Gross',
            id: 'absent_adv',
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.absenteeism})
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel:    'Age',
            emptyText:     'Select Age...',
            allowBlank: true,
            id: 'age_adv',
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.age})
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Gender',
            emptyText:  'Select Gender...',
            allowBlank: true,
            id: 'gender_adv',
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.gender})
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Grade',
            emptyText:  'Select Grade...',
            allowBlank: true,
            id: 'grade_adv',
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.grade})
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'School',
            emptyText:  'Select School...',
            allowBlank: true,
            id: 'school_adv',
            displayField: 'display_name',
            store: new Ext.data.JsonStore({fields: ['id', 'display_name'], data: config.options.schools}),
            listeners:{
              select: function(comboBox, record, index){
                Ext.getCmp('school_type_adv').clearValue();
                Ext.getCmp('zip_adv').clearValue();
              }
            }
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'School Type',
            emptyText:  'Select School Type...',
            allowBlank: true,
            id: 'school_type_adv',
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.school_type}),
            listeners:{
              select: function(comboBox, record, index){
                Ext.getCmp('school_adv').clearValue();
                Ext.getCmp('zip_adv').clearValue();
              }
            }
          })
        },{
          items:{
            fieldLabel:    'Start Date',
            name:          'startdt_adv',
            id:            'startdt_adv',
            xtype:         'datefield',
            endDateField:  'enddt_adv',
            emptyText:     'Select Start Date...',
            allowBlank: true,
            ctCls: 'ux-combo-box-cls'
          }
        },{
          items:{
            fieldLabel:     'End Date',
            name:           'enddt_adv',
            id:             'enddt_adv',
            xtype:          'datefield',
            startDateField: 'startdt_adv',
            emptyText:      'Select End Date...',
            allowBlank: true,
            ctCls: 'ux-combo-box-cls'
          }
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Symptoms',
            emptyText:  'Select Symptom...',
            allowBlank: true,
            id: 'symptoms_adv',
            displayField: 'name',
            valueField: 'icd9_code',
            hiddenName: 'icd9_code_adv',
            store: new Ext.data.JsonStore({fields: ['id', 'name', 'icd9_code'], data: config.options.symptoms}),
            tpl: new Ext.XTemplate(
              '<tpl for="."><div ext:qtip="{name} - {icd9_code}" class="x-combo-list-item">{name} - {icd9_code}</div></tpl>'
            )
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Zipcode',
            emptyText:  'Select Zipcode...',
            allowBlank: true,
            id: 'zip_adv',
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.zipcode}),
            listeners:{
              select: function(comboBox, record, index){
                Ext.getCmp('school_adv').clearValue();
                Ext.getCmp('school_type_adv').clearValue();
              }
            }
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Data Function',
            emptyText:  'Raw',
            id: 'data_func_adv',
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.data_functions_adv})
          })
        },{
          cls: 'base-line-check',
          items:{
            xtype: 'checkbox',
            id: 'enrolled_base_line_adv',
            boxLabel: "Display Total Enrolled Base Line"
          }
        },{
        cls: 'clear',
        items:{
          xtype:   'button',
          text:    "Switch to Simple View >>",
          style:   {
            margin: '0px 0px 5px 5px'
          },
          scope:   this,
          handler: function(buttonEl, eventObj){
            this.hide();
            Ext.getCmp('simple_query_select').show();
          }
        }
      }]
    });
    Talho.Rollcall.AdvancedADSTContainer.superclass.constructor.call(this, config);
  }
});
