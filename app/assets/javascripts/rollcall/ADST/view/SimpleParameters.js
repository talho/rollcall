//= rollcall/ux/ComboBox.js

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.SimpleParameters = Ext.extend(Ext.Panel, {
  id: "simple_query_select",
  itemId: "simple_query_select",
  layout: 'auto',
  defaults: {
    xtype:  'container',
    layout: 'form',
    cls:    'ux-layout-auto-float-item',
    style:  {
      width:    '200px',
      minWidth: '200px'
    },
    defaults: {
      width: 200
    }
  },
  
  //TODO split it out to take data and bind from not init
  initComponent: function () {
    var data = this.options;
    
    this.items = [
      {items:
        {xtype: 'rollcall-combo', fieldLabel: 'Absenteeism', emptyText:'Gross', id: 'absent_simple', editable: false,
          store: new Ext.data.JsonStore({fields: ['id', 'value'], data: data.absenteeism})
        }
      },
      {items:
        {xtype: 'rollcall-combo', fieldLabel: 'School District', emptyText:'Select School District...',
          allowBlank: true, id: 'school_district_simple', itemId: 'school_district_simple',
          displayField: 'name', editable: false,
          store: new Ext.data.JsonStore({fields: ['id', 'name'], data: data.school_districts}),
          listeners: {
            select: function(comboBox, record, index) {
              Ext.getCmp('school_simple').clearValue();
              Ext.getCmp('school_type_simple').clearValue(); 
            }
          }
        }
      },
      {items:
        {xtype: 'rollcall-combo', fieldLabel: 'School', emptyText:'Select School...', allowBlank: true, 
          id: 'school_simple', itemId: 'school_simple', displayField: 'display_name', editable: false,
          store: new Ext.data.JsonStore({fields: ['id', 'display_name'], data: data.schools}),
          listeners: {
            select: function(comboBox, record, index){
              Ext.getCmp('school_district_simple').clearValue();
              Ext.getCmp('school_type_simple').clearValue();
              Ext.getCmp('return_individual_school_simple').setValue(true);               
            }
          }
        }
      },
      {items:
        {xtype: 'rollcall-combo', fieldLabel: 'School Type', emptyText:'Select School Type...', allowBlank: true,
          id: 'school_type_simple', itemId: 'school_type_simple', editable: false,
          store: new Ext.data.JsonStore({fields: ['id', 'value'], data: data.school_type}),
          listeners: {
            select: function(comboBox, record, index){
              Ext.getCmp('school_district_simple').clearValue();
              Ext.getCmp('school_simple').clearValue();
            }
          }
        }
      },
      {items:
        {xtype: 'datefield', fieldLabel: 'Start Date', name: 'startdt_simple', id: 'startdt_simple',
          endDateField: 'enddt_simple', emptyText:'Select Start Date...', allowBlank: true,
          selectOnFocus:true, ctCls: 'ux-combo-box-cls'
        }
      },
      {items:
        {xtype: 'datefield', fieldLabel: 'End Date', name: 'enddt_simple', id: 'enddt_simple',
          startDateField: 'startdt_simple', emptyText:'Select End Date...', allowBlank: true,
          selectOnFocus:true, ctCls: 'ux-combo-box-cls'
        }
      },
      {items:
        {xtype: 'rollcall-combo', fieldLabel: 'Data Function', emptyText: 'Raw', id: 'data_func_simple', editable: false,
          store: new Ext.data.JsonStore({fields: ['id', 'value'], data: data.data_functions})
        }
      },
      {items:
        {xtype: 'container', cls: 'line-check-simple', items:[
          {xtype: 'checkbox', id: 'return_individual_school_simple', checked: true, 
            boxLabel: "Return Individual School Results"
          }]
        }
      },
      {items:
        {xtype: 'container', cls: 'clear', items: [
          {xtype: 'button', text: "Switch to Advanced View >>", style:{margin: '0px 0px 5px 5px'}, scope: this,
            handler: function(buttonEl, eventObj) {
              this.hide();
              // Ext.getCmp('rollcall_adst')._resetForm();
              // Ext.getCmp('advanced_query_select').show();
              // Ext.getCmp('advanced_query_select').doLayout();
            }
          }]
        }
      }
    ];
    
    Talho.Rollcall.ADST.view.SimpleParameters.superclass.initComponent.apply(this, arguments);
  },
});
