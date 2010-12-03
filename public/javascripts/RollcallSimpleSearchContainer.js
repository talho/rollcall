Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.RollcallSimpleSearchContainer = Ext.extend(Ext.Container, {
  constructor: function(config)
  {
    Ext.applyIf(config, {
      title: "Simple Query Select",
      id: "simple_query_select",
      itemId: "simple_query_select",
      layout: 'auto',    
      padding: '0 0 5 5',
      defaults:{
        xtype: 'container',
        layout: 'form',
        cls: 'ux-layout-auto-float-item',
        style: {
          width: 'auto',
          minWidth: '200px'
        },
        defaults:{
          width: 200
        }
      },
      items:[{
        items:
          new Talho.Rollcall.ux.comboBoxConfig({
            fieldLabel: 'Absenteeism',
            emptyText:'Gross',
            id: 'absent_simple',
            store: config.absenteeism
          })
        },{
        items:
          new Talho.Rollcall.ux.comboBoxConfig({
            fieldLabel: 'School',
            emptyText:'Select School...',
            id: 'school_simple',
            store: config.schools
          })
        },{
          items:
            new Talho.Rollcall.ux.comboBoxConfig({
              fieldLabel: 'School Type',
              emptyText:'Select School Type...',
              id: 'school_type_simple',
              store: config.school_type
            })
        },{
          items:{
            fieldLabel: 'Start Date',
            name: 'startdt_simple',
            id: 'startdt_simple',
            xtype: 'datefield',
            endDateField: 'enddt_simple',
            emptyText:'Select Start Date...',
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
            selectOnFocus:true,
            ctCls: 'ux-combo-box-cls'
          }
        },{
          items:
            new Talho.Rollcall.ux.comboBoxConfig({
              fieldLabel: 'Data Function',
              emptyText:'Raw',
              id: 'data_func_simple',
              store: config.data_functions
            })
        },{
          cls: 'clear',
          items:{
            xtype: 'button',
            text: "Switch to Advanced Search >>",
            style:{
              margin: '0px 0px 5px 5px'
            },
            scope: this,
            handler: function(buttonEl, eventObj){
              this.hide();
              Ext.getCmp('advanced_query_select').show();
              Ext.getCmp('advanced_query_select').doLayout();
            }
          }
        }]
    });
    Talho.Rollcall.RollcallSimpleSearchContainer.superclass.constructor.call(this, config);
  }
});