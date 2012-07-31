//TODO: Require Files

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.AdvancedParameters = Ext.extend(Ext.Container, {
  title: "Advanced Query Select",
  id: "advanced_query_select",
  itemId: "advanced_query_select",
  layout: 'auto',
  hidden: true,

  //TODO split it out to take data and bind from not init
  initComponent: function () {
    var data = this.options
    
    //TODO: Let's conditionalize this for School District & School
    var schoolFilter = {xtype: 'fieldset', layout: 'hbox', width: 262, title: 'School Filter',
      items: [
        {xtype: 'container', layout: 'vbox', width: 100, height: 230, defaults: { width:100 },
          items: [
            {xtype: 'label', html: 'School Type:'},
            {xtype: 'listview', id: 'school_type_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
              columns: [{dataIndex: 'value', cls:'school-type-list-item'}], hideHeaders: true, height: 90,
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: data.school_type})
            },
            {xtype: 'spacer', height: 5},
            {xtype: 'label', html: 'Zipcode:'},
            {xtype: 'listview', id: 'zip_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
              columns: [{dataIndex: 'value', cls:'zipcode-list-item'}], hideHeaders: true, height: 90,
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: data.zipcode})
            }            
          ]          
        },
        {xtype: 'spacer', width: 5},
        {xtype: 'container', layout: 'vbox', width: 135, height: 230, defaults: { width:135 },
          items: [
            {xtype: 'label', html: 'School District:'},
            {xtype: 'listview', id: 'school_district_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form', 
              columns: [{dataIndex: 'value', cls:'school-district-list-item'}], hideHeaders: true, height: 90,
              store: new Ext.data.JsonStore({fields: ['id', {name:'value', mapping:'name'}], data: data.school_districts})
            },
            {xtype: 'spacer', height: 5},
            {xtype: 'label', html: 'School Name:'},
            {xtype: 'listview', id: 'school_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
              columns: [{dataIndex: 'value', cls:'school-name-list-item'}], hideHeaders: true, height: 90,
              store: new Ext.data.JsonStore({fields: ['id', {name:'value', mapping:'display_name'}], data: data.schools})
            }
          ]
        }
      ]
    };
    
    var iliFilter = {xtype: 'fieldset', layout: 'hbox', width: 328, title: 'ILI Data Filter',
      items: [
        {xtype: 'container', layout: 'vbox', width: 120, height: 230, defaults: { width:120 },
          items: [
            {xtype: 'label', html: 'Age:'},
            {xtype: 'listview', id: 'age_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
              columns: [{dataIndex: 'value', cls: 'age-list-item'}], hideHeaders: true, height: 90,
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: data.age})
            },
            {xtype: 'spacer', height: 5},
            {xtype: 'label', html: 'Grade:'},
            {xtype: 'listview', id: 'grade_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
              columns: [{dataIndex: 'value', cls: 'grade-list-item'}], hideHeaders: true, height: 90,
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: data.grade})
            }
          ]
        },
        {xtype: 'spacer', width: 5},
        {xtype: 'container', layout: 'vbox', width: 180, height: 230, defaults: { width:180 },
          items: [
            {xtype: 'label', html: 'Symptoms:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ICD-9 Code'},
            {xtype: 'listview', id: 'symptoms_adv', multiSelect: true, simpleSelect: true, cls: 'ux-query-form',
              columns: [{dataIndex: 'name', width: 0.70, cls:'symptom-list-item'}, {dataIndex: 'value'}],
              hideHeaders: true, height: 160,
              store: new Ext.data.JsonStore({fields: ['id', 'name', {name:'value', mapping:'icd9_code'}], data: data.symptoms})
            },
            {xtype: 'spacer', height: 5},
            {xtype: 'label', html: 'Gender:'},
            {xtype: 'combo', id: 'gender_adv', fieldLabel: 'Gender', editable: false, emptyText: 'Select Gender...',
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: data.gender})
            }
          ]
        }
      ]
    };
    
    var miscFilter = {xtype: 'fieldset', layout: 'hbox', width: 252, title: 'Data Types/Date Range',
      items: [
        {xtype: 'container', layout: 'vbox', width: 110, height: 230, defaults: { width:110 },
          items: [
            {xtype: 'label', html: 'Absenteeism:'},
            {xtype: 'combo', id: 'absent_adv', fieldLabel: 'Absenteeism', editable: false, value: 'Gross',
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: data.absenteeism})
            },
            {xtype: 'spacer', height: 10},
            {xtype: 'label', html: 'Start Date:'},
            {xtype: 'datefield', fieldLabel: 'Start Date Adv', name: 'startdt_adv', id: 'startdt_adv',
              endDateField: 'enddt_adv', emptyText: 'Select Start Date...', allowBlank: true, ctCls: 'ux-combo-box-cls'
            }
          ]
        },
        {xtype: 'spacer', width: 10},
        {xtype: 'container', layout: 'vbox', width: 110, height: 230, defaults: { width:110 },
          items: [
            {xtype: 'label', html: 'Data Function:'},
            {xtype: 'combo', id: 'data_func_adv', editable: false, value: 'Raw',
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: data.data_functions_adv})
            },
            {xtype: 'spacer', height: 10},
            {xtype: 'label', html: 'End Date:'},
            {xtype: 'datefield', fieldLabel: 'End Date Adv', name: 'enddt_adv', id: 'enddt_adv',              startDateField: 'startdt_adv',
              emptyText: 'Select End Date...', allowBlank: true, ctCls: 'ux-combo-box-cls'
            }
          ]
        }
      ]
    };
       
    this.items = [
      {xtype: 'container', layout: 'hbox', height: 275, padding: '0 5', items: [
        {xtype: 'spacer', width: 5},
        schoolFilter,
        {xtype: 'spacer', width: 5},
        iliFilter,
        {xtype: 'spacer', width: 5},
        miscFilter        
      ]},
      {xtype: 'checkbox', id: 'return_individual_school_adv', cls: 'line-check', checked: true, boxLabel: "Return Individual School Results"},
      {xtype: 'button', cls: 'clear', text: 'Switch to Simple View >>', style: { margin: '6px 0px 5px 5px' },
        scope: this,
        //TODO handle this on Parameters
        handler: function(buttonEl, eventObj) {
          this.hide();
          // Ext.getCmp('rollcall_adst')._resetForm();
          // Ext.getCmp('simple_query_select').show();
        }
      }
    ];
    
    Talho.Rollcall.ADST.view.AdvancedParameters.superclass.initComponent.apply(this, arguments);
  }
});