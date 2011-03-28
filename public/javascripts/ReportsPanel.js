Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ReportsPanel = Ext.extend(Ext.grid.GridPanel, {
  constructor: function(config){
    // sample static data for the store
    var myData = [
      ['Bellaire High School'],
      ['Berry Elementary'],
      ['Lewis Elementary'],
      ['Southmayd Elementary'],
      ['Woodson Middle School']
    ];
    // create the data store
    var store = new Ext.data.ArrayStore({
      fields: [
        {name: 'school'}
      ]
    });
    // manually load local data
    store.loadData(myData);
    Ext.applyIf(config, {
      store:   store,
      id:      'reports_grid',
      itemId:  'reports_grid',
      columns: [
        {id:'school', header: 'School', width: 160, sortable: true, dataIndex: 'school'},
        {
          xtype: 'actioncolumn',
          width: 50,
          items: [{
            iconCls: 'rollcall_pdf_icon',
            tooltip: 'Download Report',
            handler: function(grid, rowIndex, colIndex) {
              var rec = store.getAt(rowIndex);
              alert("Download " + rec.get('school') + " PDF");
            }
          }]
        }
      ],
      stripeRows: true,
      autoExpandColumn: 'school',
      autoHeight: true,
      autoWidth: true,
      stateful: true,
      stateId: 'grid'
    });
    Talho.Rollcall.ReportsPanel.superclass.constructor.call(this, config);
  },

  load_report_window: function()
  {
    var win = new Ext.Window({
      title:       'Create Report',
      layout:      'fit',
      modal:       true,
      constrain:   true,
      renderTo:    'adst_container',
      closeAction: 'close',
      width:       400,
      autoHeight:  true,
      //height:      625,
      plain:       true,
      items: [{
        xtype: 'form',
        border: false,
        method: 'PUT',
        bodyStyle:   'padding:0px 3px',
        defaults:    {
          xtype:       'fieldset',
          autoHeight:  true,
          layout:      'form',
          collapsed:   false,
          collapsible: false,
          width:       375
        },
        items:[{
          title:    'Report',
          defaults: {
            xtype:  'container',
            layout: 'form',
            cls:    'ux-layout-auto-float-item'
          },
          items:[{
            items: {
              xtype:         'textfield',
              width:         175,
              fieldLabel:    'Report Name',
              id:            'report_name',
              allowBlank:    false,
              blankText:     "This field is required.",
              minLength:     3,
              minLengthText: 'The minimum length for this field is 3.',
              style:         {
                marginLeft: '-2px'
              }
            }
          },{
            items: new Talho.Rollcall.ux.ComboBox({
              fieldLabel: 'Report Type',
              emptyText:  'Please select report to run...',
              id:         'report_absent',
              width:      175,
              store:      new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('absenteeism')})
            })
          }]
        },{
          title:    'Data Functions',
          defaults: {
            style: {
              width:    '350px'
            }
          },
          items: [{
            border: false,
            items:{
              xtype:      'checkboxgroup',
              columns:    2,
              border:     false,
              items: [
                {boxLabel: 'Raw',                name: 'cb-horiz-1', checked: true},
                {boxLabel: 'Average',            name: 'cb-horiz-2'},
                {boxLabel: 'Standard Deviation', name: 'cb-horiz-3'},
                {boxLabel: 'Moving Avg 30 Day',  name: 'cb-horiz-4'},
                {boxLabel: 'Moving Avg 60 Day',  name: 'cb-horiz-5'},
                {boxLabel: 'Cusum',              name: 'cb-horiz-6'}
              ]
            }
          }]
        },{
          title:    'Filter Schools By',
          defaults: {
            xtype:  'container',
            layout: 'form',
            cls:    'ux-layout-auto-float-item'
          },
          items:[{
            items:
              new Talho.Rollcall.ux.ComboBox({
                fieldLabel:   'School',
                emptyText:    'Select School...',
                allowBlank:    true,
                id:           'report_school',
                itemId:       'report_school',
                displayField: 'display_name',
                width:         175,
                store:        new Ext.data.JsonStore({fields: ['id', 'display_name'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('schools')}),
                listeners:{
                  select: function(comboBox, record, index)
                  {
                    Ext.getCmp('report_school_type').clearValue();
                  }
                }
              })
          },{
            items:
              new Talho.Rollcall.ux.ComboBox({
                fieldLabel: 'School Type',
                emptyText:'Select School Type...',
                allowBlank: true,
                id:        'report_school_type',
                itemId:    'report_school_type',
                width:     175,
                store:     new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('school_type')}),
                listeners: {
                  select: function(comboBox, record, index){
                    Ext.getCmp('report_school').clearValue();
                  }
                }
              })
          },{
            items: new Talho.Rollcall.ux.ComboBox({
              fieldLabel: 'Zipcode',
              emptyText:  'Select Zipcode...',
              allowBlank: true,
              id: 'report_zip',
              itemId: 'report_zip',
              width:         175,
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('zipcode')}),
              listeners:{
                select: function(comboBox, record, index){
                  Ext.getCmp('report_school').clearValue();
                  Ext.getCmp('report_school_type').clearValue();
                }
              }
            })
          }]
        },{
          title:    'Filter Student Data By',
          defaults: {
            xtype:  'container',
            layout: 'form',
            cls:    'ux-layout-auto-float-item'
          },
          items:[{
            items: new Talho.Rollcall.ux.ComboBox({
              fieldLabel:    'Age',
              emptyText:     'Select Age...',
              allowBlank: true,
              id: 'report_age',
              width:         175,
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('age')})
            })
          },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Gender',
            emptyText:  'Select Gender...',
            allowBlank: true,
            id: 'report_gender',
            width:         175,
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('gender')})
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Grade',
            emptyText:  'Select Grade...',
            allowBlank: true,
            id: 'report_grade',
            width:         175,
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('grade')})
          })
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Symptoms',
            emptyText:  'Select Symptom...',
            allowBlank: true,
            id: 'report_symptoms',
            displayField: 'name',
            width:         175,
            store: new Ext.data.JsonStore({fields: ['id', 'name'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('symptoms')})
          })
        }]
      },{
          title:    'Filter By Date Range',
          defaults: {
            xtype:  'container',
            layout: 'form',
            cls:    'ux-layout-auto-float-item'
          },
          items:[{
            items:{
              fieldLabel:    'Start Date',
              name:          'report_startdt',
              id:            'report_startdt',
              xtype:         'datefield',
              endDateField:  'report_enddt',
              emptyText:     'Select Start Date...',
              allowBlank: true,
              ctCls: 'ux-combo-box-cls',
              width: 175
            }
          },{
            items:{
              fieldLabel:     'End Date',
              name:           'report_enddt',
              id:             'report_enddt',
              xtype:          'datefield',
              startDateField: 'report_startdt',
              emptyText:      'Select End Date...',
              allowBlank: true,
              ctCls: 'ux-combo-box-cls',
              width: 175
            }
          }]
      }]
      }],
      buttonAlign: 'right',
      buttons: [{
        text:'Save',
        handler: function(buttonEl, eventObj){}
      },{
        text: 'Cancel',
        handler: function(buttonEl, eventObj){
          win.close();
        }
      }]
    });
    win.doLayout();
    win.show();
  }
});