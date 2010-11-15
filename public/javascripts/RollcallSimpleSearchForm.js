Ext.namespace('Talho.ux.rollcall');

Talho.ux.rollcall.RollcallSimpleSearchForm = Ext.extend(Ext.form.FormPanel, {
  constructor: function(config)
  {
    Ext.applyIf(config, {
      columnWidth: 1,
      collapsible: false,
      labelAlign: 'top',
      title: "Simple Query Select",
      id: "simple_query_select",
      itemId: "simple_query_select",
      padding: '0 0 5 5',
      style: "padding-right: 5px",
      url:'',
      buttonAlign: 'left',
      buttons: [{
        text: "Submit",
        scope: this,
        handler: function(buttonEl, eventObj){
          Ext.getCmp('searchResultPanel').show();
          Ext.getCmp('searchResultPanel').processQuery();
          Ext.getCmp('rollcall_search').doLayout();
        },
        formBind: true
      },{
        text: "Cancel",
        handler: this.clearForm
      }],
      items: [{
        xtype: 'container',
        id: "queryFormContainer",
        layout: 'hbox',
        lazyRender: true,
        defaults:{
          xtype:  'fieldset',
          border: false
        },
        items:[{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'Absenteeism',
            emptyText:'Gross',
            id: 'absentSimpleBox',
            store: config.absenteeism
          })
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'School',
            emptyText:'Select School...',
            id: 'schoolSimpleBox',
            store: config.schools
          })
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'School Type',
            emptyText:'Select School Type...',
            id: 'schoolTypeSimpleBox',
            store: config.school_type
          })
        },{
          items:[{
            xtype: 'checkbox',
            width: 75,
            boxLabel: "Include",
            name: "include_school",
            id: "include_school"
          }]
        },{
          items:[{
            fieldLabel: 'Start Date',
            name: 'startdt',
            id: 'startdt',
            xtype: 'datefield',
            width: 182,
            endDateField: 'enddt', // id of the end date field
            emptyText:'Select Start Date...',
            selectOnFocus:true
          }]
        },{
          items:[{
            fieldLabel: 'End Date',
            name: 'enddt',
            id: 'enddt',
            xtype: 'datefield',
            width: 182,
            startDateField: 'startdt', // id of the start date field
            emptyText:'Select End Date...',
            selectOnFocus:true
          }]
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'Data Function',
            emptyText:'Raw',
            id: 'dataFunctionSimpleBox',
            store: config.data_functions
          })
        }]
      },{
        xtype: 'container',
        layout: 'auto',
        lazyRender: true,
        items:[{
          xtype: 'button',
          text: "Switch to Advanced Search >>",
          style:{
            marginLeft: '10px'
          },
          scope: this,
          handler: function(buttonEl, eventObj){
            Ext.getCmp('simple_query_select').hide();
            Ext.getCmp('advanced_query_select').show();
          }
        }]
      }]
    });
    Talho.ux.rollcall.RollcallSimpleSearchForm.superclass.constructor.call(this, config);
  }
});