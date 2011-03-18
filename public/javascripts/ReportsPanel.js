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
      store: store,
      id: 'report_panel',
      itemId: 'report_panel',
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
      // config options for stateful behavior
      stateful: true,
      stateId: 'grid'
    });
    //Ext.apply(this, config);
    Talho.Rollcall.ReportsPanel.superclass.constructor.call(this, config);
  },

  load_report_window: function()
  {
    var win = new Ext.Window({
      title:       'Create Report',
      layout:      'vbox',
      padding:     '5',
      //autoHeight:  true,
      modal:       true,
      constrain:   true,
      renderTo:    'adst_container',
      closeAction: 'close',
      width:       400,
      height:      625,
      plain:       true,
      style:{
        width: '300px'  
      },
      defaults:{
        xtype:  'container',
        layout: 'form',
        cls:    'ux-layout-auto-float-item',
        style: {
          minWidth: '355px'
        }
      },
      items: [{
        xtype: 'fieldset',
        title: 'Report',
        autoHeight: true,
        layout: 'form',
        collapsed: false,
        collapsible: false,
        defaults: {
          xtype:  'container',
          layout: 'form',
          cls:    'ux-layout-auto-float-item',
          style:  {
            width:    'auto',
            minWidth: '200px'
          },
          defaults: {
            width: 200
          }
        },
        items:[{
          xtype:'textfield',
          labelStyle: 'margin: 0px 0px 0px 5px',
          fieldLabel: 'Report Name',
          //value: alarm_query_title,
          id: 'report_name',
          allowBlank: false,
          blankText: "This field is required.",
          minLength: 3,
          minLengthText: 'The minimum length for this field is 3.'
        },{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel: 'Report Type',
            emptyText:  'Please select report to run...',
            id:         'report_absent',
            store:      new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('absenteeism')})
          })
        }]
      },{
        xtype: 'fieldset',
        title: 'Data Functions',
        autoHeight: true,
        layout: 'form',
        collapsed: false,   // initially collapse the group
        collapsible: false,
        items: [{
          items:{
            xtype:      'checkboxgroup',
            //fieldLabel: 'Select Data Functions',
            columns:    2,
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
        xtype: 'fieldset',
        title: 'Filter Schools By',
        autoHeight: true,
        layout: 'form',
        collapsed: false,   // initially collapse the group
        collapsible: false,
        defaults: {
          xtype:  'container',
          layout: 'form',
          cls:    'ux-layout-auto-float-item',
          style:  {
            width:    'auto',
            minWidth: '200px'
          },
          defaults: {
            width: 200
          }
        },
        items:[{
          items:
            new Talho.Rollcall.ux.ComboBox({
              fieldLabel: 'School',
              emptyText:'Select School...',
              allowBlank: true,
              id: 'report_school',
              itemId: 'report_school',
              displayField: 'display_name',
              store: new Ext.data.JsonStore({fields: ['id', 'display_name'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('schools')}),
              listeners:{
                select: function(comboBox, record, index){
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
              id: 'report_school_type',
              itemId: 'report_school_type',
              store: new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('school_type')}),
              listeners:{
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
        xtype: 'fieldset',
        title: 'Filter Student Data By',
        autoHeight: true,
        layout: 'form',
        collapsed: false,   // initially collapse the group
        collapsible: false,
        defaults: {
          xtype:  'container',
          layout: 'form',
          cls:    'ux-layout-auto-float-item',
          style:  {
            width:    'auto',
            minWidth: '200px'
          },
          defaults: {
            width: 200
          }
        },
        items:[{
          items: new Talho.Rollcall.ux.ComboBox({
            fieldLabel:    'Age',
            emptyText:     'Select Age...',
            allowBlank: true,
            id: 'report_age',
            store: new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('age')})
          })
        },{
        items: new Talho.Rollcall.ux.ComboBox({
          fieldLabel: 'Gender',
          emptyText:  'Select Gender...',
          allowBlank: true,
          id: 'report_gender',
          store: new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('gender')})
        })
      },{
        items: new Talho.Rollcall.ux.ComboBox({
          fieldLabel: 'Grade',
          emptyText:  'Select Grade...',
          allowBlank: true,
          id: 'report_grade',
          store: new Ext.data.JsonStore({fields: ['id', 'value'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('grade')})
        })
      },{
        items: new Talho.Rollcall.ux.ComboBox({
          fieldLabel: 'Symptoms',
          emptyText:  'Select Symptom...',
          allowBlank: true,
          id: 'report_symptoms',
          displayField: 'name',
          store: new Ext.data.JsonStore({fields: ['id', 'name'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('symptoms')})
        })
      }]
    },{
        xtype: 'fieldset',
        title: 'Filter By Date Range',
        autoHeight: true,
        layout: 'form',
        collapsed: false,   // initially collapse the group
        collapsible: false,
        defaults: {
          xtype:  'container',
          layout: 'form',
          cls:    'ux-layout-auto-float-item',
          style:  {
            width:    'auto',
            minWidth: '200px'
          },
          defaults: {
            width: 200
          }
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
            ctCls: 'ux-combo-box-cls'
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
            ctCls: 'ux-combo-box-cls'
          }
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
    win.show();
  }
});