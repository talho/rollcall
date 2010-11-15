Ext.namespace('Talho.ux.rollcall');

Talho.ux.rollcall.RollcallAdvancedSearchForm = Ext.extend(Ext.form.FormPanel, {
  constructor: function(config)
  {
    Ext.applyIf(config, {
      columnWidth: 1,
      labelAlign:  'top',
      title:       "Advanced Query Select",
      id:          "advanced_query_select",
      itemId:      "advanced_query_select",
      hidden:      true,
      hideMode:    "display",
      padding:     '0 0 5 5',
      style:       "padding-left: 5px",
      url:         '',
      buttonAlign: 'left',
      buttons: [{
        text:    "Submit",
        scope:   this,
        handler: function(buttonEl, eventObj){
          Talho.ux.rollcall.RollcallSearchResultPanel.show();
          Ext.getCmp('rollcall_search').doLayout();
        },
        formBind: true
      },{
        text:    "Cancel",
        handler: this.clearForm
      }],
      items: [{
        xtype:      'container',
        layout:     'hbox',
        lazyRender: true,
        defaults: {
          xtype:  'fieldset',
          border: false
        },
        items:[{
          align: 'middle',
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'Absenteeism',
            emptyText:  'Gross',
            id: 'absentAdvancedBox',
            store: config.absenteeism
          })
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel:    'Age',
            emptyText:     'Select Age...',
            selectOnFocus: true,
            store: config.age
          })
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'Gender',
            emptyText:  'Select Gender...',
            store: config.gender
          })
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'Grade',
            emptyText:  'Select Grade...',
            store: config.grade
          })
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'School',
            emptyText:  'Select School...',
            id: 'schoolAdvancedBox',
            store: config.schools
          })
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'School Type',
            emptyText:  'Select School Type...',
            id: 'schoolTypeAdvancedBox',
            store: config.school_type
          })
        }]
      },{
        xtype:      'container',
        layout:     'hbox',
        lazyRender: true,
        defaults: {
          xtype: 'fieldset',
          border: false
        },
        items:[{
          items:[{
            fieldLabel:    'Start Date',
            name:          'startdt_adv',
            id:            'startdt_adv',
            xtype:         'datefield',
            width:         182,
            endDateField:  'enddt_adv', // id of the end date field
            emptyText:     'Select Start Date...',
            selectOnFocus: true
          }]
        },{
          items:[{
            fieldLabel:     'End Date',
            name:           'enddt_adv',
            id:             'enddt_adv',
            xtype:          'datefield',
            width:          182,
            startDateField: 'startdt_adv', // id of the start date field
            emptyText:      'Select End Date',
            selectOnFocus:  true
          }]
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'Symptoms',
            emptyText:  'Select Symptoms...',
            store: config.symptons
          })
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'Temperature',
            emptyText:  'Select Temperature...',
            store: config.temperature
          })
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'Zipcode',
            emptyText:  'Select Zipcode...',
            store: config.zipcode
          })
        },{
          items: new Talho.ux.rollcall.comboBoxConfig({
            fieldLabel: 'Data Function',
            emptyText:  'Raw',
            id: 'dataFunctionAdvancedBox',
            store: config.data_functions
          })
        }]
      },{
        xtype:      'container',
        layout:     'auto',
        lazyRender: true,
        items:[{
          xtype:   'button',
          text:    "Switch to Simple Search >>",
          style:   {
            marginLeft: '10px'
          },
          scope:   this,
          handler: function(buttonEl, eventObj){
            Ext.getCmp('advanced_query_select').hide();
            Ext.getCmp('simple_query_select').show();
          }
        }]
      }]
    });
    Talho.ux.rollcall.RollcallAdvancedSearchForm.superclass.constructor.call(this, config);
  }
});