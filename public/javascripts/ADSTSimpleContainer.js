Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ADSTSimpleContainer = Ext.extend(Ext.Container, {
  constructor: function(config)
  {
    Ext.applyIf(config, {
      title:    "Simple Query Select",
      id:       "simple_query_select",
      itemId:   "simple_query_select",
      layout:   'auto',
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
      items:[{
        items:
          new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Absenteeism',
            emptyText:'Gross',
            id: 'absent_simple',
            editable:   false,
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.absenteeism})
          })
        },{
        items:
          new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'School',
            emptyText:'Select School...',
            allowBlank: true,
            id: 'school_simple',
            itemId: 'school_simple',
            displayField: 'display_name',
            editable:   false,
            store: new Ext.data.JsonStore({fields: ['id', 'display_name'], data: config.options.schools}),
            listeners:{
              select: function(comboBox, record, index){
                Ext.getCmp('school_type_simple').clearValue();
              }
            }
          })
        },{
        items:
          new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'School Type',
            emptyText:'Select School Type...',
            allowBlank: true,
            id: 'school_type_simple',
            itemId: 'school_type_simple',
            editable:   false,
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.school_type}),
            listeners:{
              select: function(comboBox, record, index){
                Ext.getCmp('school_simple').clearValue();
              }
            }
          })
        },{
          items:{
            fieldLabel: 'Start Date',
            name: 'startdt_simple',
            id: 'startdt_simple',
            xtype: 'datefield',
            endDateField: 'enddt_simple',
            emptyText:'Select Start Date...',
            allowBlank: true,
            selectOnFocus:true,
            ctCls: 'ux-combo-box-cls'
          }
        },{
          items:{
            fieldLabel: 'End Date',
            name: 'enddt_simple',
            id: 'enddt_simple',
            xtype: 'datefield',
            startDateField: 'startdt_simple',
            emptyText:'Select End Date...',
            allowBlank: true,
            selectOnFocus:true,
            ctCls: 'ux-combo-box-cls'
          }
        },{
          items:
            new Talho.Rollcall.ux.ComboBox({
              fieldLabel: 'Data Function',
              emptyText:'Raw',
              id: 'data_func_simple',
              editable:   false,
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: config.options.data_functions})
            })
        },{
          cls: 'base-line-check',
          items:{
            xtype: 'checkbox',
            id: 'enrolled_base_line_simple',
            boxLabel: "Display Total Enrolled Base Line"
          }
        },{
          cls: 'clear',
          items:{
            xtype: 'button',
            text: "Switch to Advanced View >>",
            style:{
              margin: '0px 0px 5px 5px'
            },
            scope: this,
            handler: function(buttonEl, eventObj){
              this.hide();
              Ext.getCmp('rollcall_adst').resetForm();
              Ext.getCmp('advanced_query_select').show();
              Ext.getCmp('advanced_query_select').doLayout();
            }
          }
        }]
    });
    Talho.Rollcall.ADSTSimpleContainer.superclass.constructor.call(this, config);
  }
});
