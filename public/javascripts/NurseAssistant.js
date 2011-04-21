Ext.ns('Talho.Rollcall');

Talho.Rollcall.NurseAssistant = Ext.extend(function(){}, {
  constructor: function(config){
    this.build_detail_template();
    this.window_open    = false;
    this.user_school_id = null;
    this.init_store     = new Ext.data.JsonStore({
      root:      'options',
      fields:    ['race', 'age', 'gender', 'grade', 'symptoms', 'zip', 'total_enrolled_alpha', 'app_init', 'school_id', 'schools', 'school_name'],
      url:       '/rollcall/nurse_assistant_options',
      autoLoad:  true,
      listeners: {
        scope: this,
        load:  function(this_store, records){
          if(this_store.getAt(0).get("app_init") == true){
            this.setup_app();
          }else{
            this.getPanel().get(0).getBottomToolbar().getComponent('new_student_btn').enable();
            this.getPanel().get(0).getBottomToolbar().getComponent('settings-btn').enable();
            this.student_list_store.load({
              params:{
                school_id: this_store.getAt(0).get('school_id')
              }
            });
            this.user_school_id = this_store.getAt(0).get('school_id');
            this.main_panel_store.load({
              params:{
                school_id: this.user_school_id
              }
            });
            this.getPanel().get(0).setTitle('Current Student Visits for '+this_store.getAt(0).get('school_name'));
          }
        }
      }
    });

    this.student_list_store = new Ext.data.JsonStore({
      fields:    ['first_name','last_name','student_number','phone','race','contact_first_name','contact_last_name','gender','dob','zip','address','grade'],
      root:      'results',
      url:       '/rollcall/students',
      autoLoad:  false,
      restful:   true
    });
    
    this.student_reader = new Ext.data.JsonReader({
      root:          'results',
      totalProperty: 'total_results',
      fields: [
        {name:'id',                 type:'string'},
        {name:'student_id',         type:'integer'},
        {name:'first_name',         type:'string'},
        {name:'last_name',          type:'string'},
        {name:'contact_first_name', type:'string'},
        {name:'contact_last_name',  type:'string'},
        {name:'symptom',            type:'string'},
        {name:'treatment',          type:'string'},
        {name:'grade',              type:'integer'},
        {name:'address',            type:'string'},
        {name:'zip',                type:'string'},
        {name:'phone',              type:'string'},
        {name:'gender',             type:'string'},
        {name:'race',               type:'integer'},
        {name:'temperature',        type:'integer'},
        {name:'treatment',          type:'string'},
        {name:'dob',                renderer: Ext.util.Format.dateRenderer('m-d-Y')},
        {name:'student_number',     type:'integer'},
        {name:'report_date',        renderer: Ext.util.Format.dateRenderer('m-d-Y')}
      ]
    });

    this.main_panel_store = new Ext.data.GroupingStore({
      autoLoad:       false,
      autoDestroy:    true,
      autoSave:       true,
      reader:         this.student_reader,
      writer:         new Ext.data.JsonWriter({encode: false}),
      url:            '/rollcall/nurse_assistant',
      sortInfo:       {field: 'report_date'},
      groupField:     'report_date',
      restful:        true,
      baseParams:     {
        filter_report_date: new Date(),
        school_id:          this.user_school_id
      },
      listeners: {
        scope: this,
        load:  function(this_store, records){
          this.getPanel().doLayout();
          if(records.length != 0){
            this.getPanel().getComponent('student_detail_panel').update('');
            this.getPanel().getComponent('nurse_assistant').getSelectionModel().selectRow(0);
            this.getPanel().getComponent('nurse_assistant').fireEvent('rowclick', this.getPanel().getComponent('nurse_assistant'),0);
          }else{
            this.getPanel().getComponent('student_detail_panel').getComponent('history_grid').hide();
            this.getPanel().getComponent('student_detail_panel').getComponent('student-stats').update('<div class="details"><div class="details-info"><span>No records</span></div></div>');
            this.build_detail_template();
          }
        }
      }
    });

    var main_panel = new Ext.Panel({
      title:    config.title,
      itemId:   config.id,
      layout:   'border',
      closable: true,
      items:    [{
        xtype:    'grid',
        region:   'center',
        title:    'Current Student Visits',
        id:       'nurse_assistant',
        itemId:   'nurse_assistant',
        frame:    'true',
        store:    this.main_panel_store,
        cm:       new Ext.grid.ColumnModel({
          columns: [
            {id:'student_number',    header:'Student Number',     dataIndex:'student_number'},
            {id:'first_name_column', header:'Student First Name', dataIndex:'first_name', width: 125},
            {id:'last_name_column',  header:'Student Last Name',  dataIndex:'last_name',  width: 125},
            {id:'symptom_column',    header:'Symptoms',           dataIndex:'symptom'},
            {id:'header',            header:'Action',             dataIndex:'treatment',  width: 175},
            {id:'visit_date',        header:'Visit Date',         dataIndex:'report_date'},
            {
              xtype:     'xactioncolumn',
              items:     [{icon:'/stylesheets/images/pencil.png'}],
              listeners: {
                scope: this,
                click: function(this_column, this_grid, row_index, event_obj)
                {
                  this.window_open = true;
                  this.student_entry_window(this.main_panel_store.getAt(row_index));
                }
              }
            },{
              xtype:     'xactioncolumn',
              items:     [{icon:'/stylesheets/images/cross-circle.png'}],
              listeners: {
                scope: this,
                click: function(this_column, this_grid, row_index, event_obj)
                {
                  this.window_open = true;
                  var record_index = row_index;
                  Ext.MessageBox.show({
                    title:   'Delete Student Visit',
                    msg:     'Are you sure you want to delete this recorded visitation? This can not be undone.',
                    buttons: {
                      ok:     'Yes',
                      cancel: 'No'
                    },
                    scope: this,
                    icon:  Ext.MessageBox.QUESTION,
                    fn:    function(btn_ok,txt,cfg_obj)
                    {
                      this.window_open = false;
                      if(btn_ok == 'ok') this.main_panel_store.removeAt(record_index);
                    }
                  });
                }
              }
            }
          ]
        }),
        viewConfig: {
          emptyText:     '<div><b style="color:#000">There are no student visits for this date</b></div>',
          enableRowBody: true
        },
        autoExpandColumn: 'symptom_column',
        bbar:             new Ext.PagingToolbar({
          store: this.main_panel_store,
          items: [
            {text: 'New', iconCls:'add_forum', itemId:'new_student_btn', disabled: true, handler: function(){this.student_entry_window();}, scope: this},
            {text: 'Change School', iconCls:'settings-btn', itemId: 'settings-btn', disabled: true, handler: this.setup_app, scope: this},
            '->',
            {xtype: 'textfield', id: 'search_field'},
            {xtype: 'button',    text: 'Search', scope:this, handler: this.search_student},
          ]
        }),
        tbar: {
          items: ['->',{
            fieldLabel:    'Visit Date',
            name:          'visit_date',
            id:            'visit_date',
            xtype:         'datefield',
            emptyText:     'Visit Date...',
            allowBlank:    true,
            selectOnFocus: true,
            width:         200,
            style:         {
              marginRight: '-4px'
            },
            listeners:{
              scope:  this,
              select: function (this_datefield, selected_date)
              {
                this.update_student_detail_panel_msg();
                this.main_panel_store.load({
                  params:{
                    filter_report_date: selected_date,
                    school_id: this.user_school_id
                  }
                });
              },
              afterrender: function (this_datefield)
              {
                this_datefield.setValue(new Date());
              }
            }
          }]
        },
        listeners: {
          scope:    this,
          rowclick: this.show_details,
          afterrender: function(this_panel)
          {
            this.init_mask = new Ext.LoadMask(this_panel.getEl(), {store: this.main_panel_store});
            this.init_mask.show();
            this_panel.doLayout();
          }
        }
      },{
        id:       'student_detail_panel',
        title:    'Student Information',
        region:   'east',
        split:    true,
        width:    350,
        minWidth: 350,
        maxWidth: 350,
        padding:  5,
        items:    [{
          xtype: 'container',
          id:    'student-stats',
          html:  '<div class="details"><div class="details-info"><span>Loading Data..</span></div></div>'
        },{
          xtype:      'grid',
          id:         'history_grid',
          loadMask:   true,
          autoHeight: true,
          hidden:     true,
          store: new Ext.data.JsonStore({
            fields:   ['report_date','symptom','treatment','temperature'],
            root:     'results',
            url:      '/rollcall/students/history',
            autoLoad: false
          }),
          cm: new Ext.grid.ColumnModel({
            columns: [
              {id:'history_report_date', header:'Report Date', dataIndex:'report_date', width: 75},
              {id:'history_symptoms',    header:'Symptoms',    dataIndex:'symptom'},
              {id:'history_temperature', header:'Temperature', dataIndex:'temperature', width: 75},
              {id:'history_action',      header:'Action',      dataIndex:'treatment'}
            ]
          })
        }]
      }]
    });
    this.getPanel = function(){ return main_panel;};
  },

  setup_app: function()
  {
    var init_window = new Ext.Window({
      layout:    'form',
      title:     'Nurse Assistant School Setup',
      renderTo:  'nurse_assistant',
      scope:     this,
      modal:     true,
      constrain: true,
      padding:   5,
      width:     380,
      items:     [new Ext.form.ComboBox({
        fieldLabel:    'Please select your school',
        labelStyle:    'width:150px;',
        emptyText:     'Select School...',
        allowBlank:    false,
        id:            'select_school',
        store:         new Ext.data.JsonStore({fields: ['id', 'display_name'], data: this.init_store.getAt(0).get('schools')}),
        typeAhead:     true,
        triggerAction: 'all',
        mode:          'local',
        lazyRender:    true,
        autoSelect:    true,
        selectOnFocus: true,
        valueField:    'id',
        displayField:  'display_name',
        selectedIndex: null,
        listeners: {
          select: function(this_box, record, index)
          {
            this_box.selectedIndex = index;
          }
        }
      })],
      buttons: [{
        text:     'OK',
        formBind: true,
        scope:    this,
        id:       'submit_school_slct_btn',
        handler:  function(buttonEl, eventObj)
        {
          if(buttonEl.ownerCt.ownerCt.getComponent('select_school').getValue() >= 1){
            var selected_index  = buttonEl.ownerCt.ownerCt.getComponent('select_school').selectedIndex;
            var school_name     = this.init_store.getAt(0).get('schools')[selected_index].display_name;
            this.user_school_id = buttonEl.ownerCt.ownerCt.getComponent('select_school').getValue();
            this.getPanel().get(0).getBottomToolbar().getComponent('new_student_btn').enable();
            this.getPanel().get(0).getBottomToolbar().getComponent('settings-btn').enable();
            this.student_list_store.load({
              params:{
                school_id: this.user_school_id
              }
            });
            this.main_panel_store.load({
              params:{
                school_id: this.user_school_id
              }
            });
            this.getPanel().getComponent('nurse_assistant').setTitle('Current Student Visits for '+school_name);
            this.update_student_detail_panel_msg();
            buttonEl.ownerCt.ownerCt.close();
          }         
        }
      },{
        text:    'Cancel',
        width:   'auto',
        handler: function(buttonEl, eventObj)
        {
          buttonEl.ownerCt.ownerCt.close();
        }
      }]
    });
    init_window.show();
  },

  update_student_detail_panel_msg: function()
  {
    var html_string = '<div class="details"><div class="details-info"><span>Loading Data..</span></div></div>';
    this.getPanel().getComponent('student_detail_panel').getComponent('student-stats').update(html_string);
    this.getPanel().getComponent('student_detail_panel').getComponent('history_grid').hide();
  },

  search_student: function(button, event)
  {
    var field_value = button.ownerCt.getComponent('search_field').getValue();
    if(field_value.length != 0){
      this.update_student_detail_panel_msg();
      this.main_panel_store.load({
        params:{
          search_term: field_value,
          school_id:   this.user_school_id
        },
        callback: function(records, options, success)
        {
          if(records.length == 0) this.mainBody.update('<div class="x-grid-empty"><div><b style="color:#000">No student visits</b></div></div>');
        },
        scope: this.getPanel().getComponent('nurse_assistant').getView()
      });
    }  
  },

  show_details: function(grid_panel, index, event)
  {
    if(!this.window_open){
      var panel_el  = this.getPanel().getComponent('student_detail_panel');
      var detail_el = panel_el.getComponent('student-stats').getEl();
      var record    = grid_panel.getStore().getAt(index);
      panel_el.body.hide();
      this.details_template.overwrite(detail_el, record.data);
      panel_el.body.slideIn('l', {stopFx:true,duration:.3});
      this.getPanel().getComponent('student_detail_panel').getComponent('history_grid').show();
      this.getPanel().getComponent('student_detail_panel').doLayout();
      this.getPanel().getComponent('student_detail_panel').getComponent('history_grid').store.load({
        params: {
          id: record.get("student_id")
        }
      });
      this.getPanel().getComponent('student_detail_panel').doLayout();
    }   
  },

  build_detail_template: function()
  {
    this.details_template = new Ext.XTemplate(
      '<div class="details">',
        '<tpl for=".">',
          '<div class="details-info">',
            '<div>',
              '<b>Student ID:</b>',
              '<span>{student_number}</span>',
            '</div>',
            '<div class="left">',
              '<b>Phone:</b>',
              '<span>{phone}</span>',
              '<b>Gender:</b>',
              '<span>{gender}</span>',
              '<b>Race:</b>',
              '<span>{race}</span>',
              '<b>Date of Birth:</b>',
              '<span>{dob}</span><br/><br/>',
            '</div>',
            '<div>',
              '<b>Student Name:</b>',
              '<span>{first_name}&nbsp;{last_name}</span>',
              '<b>Contact Name:</b>',
              '<span>{contact_first_name}&nbsp;{contact_last_name}</span>',
              '<b>Current Grade:</b>',
              '<span>{grade}</span>',
              '<b>Address:</b>',
              '<span>{address}</span><br/>',
              '<span>{zip}</span>',             
            '</div>',
          '</div>',
        '</tpl>',
      '</div>'
		);
		this.details_template.compile();
  },

  student_entry_window: function()
  {
    this.window_open   = true;
    var argv           = this.student_entry_window.arguments;
    var student_record = {};
    var form_method    = 'POST';
    var form_url       = '/rollcall/students';
    var symptom_data   = [];
    var panel_mask     = null;

    if(argv.length != 0){
      student_record    = argv[0].data;
      student_record.id = argv[0].get('id');
      form_method       = 'PUT';
      form_url         += '/'+student_record.id;
      for(i=0;i<student_record.symptom.split(',').length;i++){
        symptom_data.push({name: student_record.symptom.split(',')[i]})
      }
      student_record.grade += 1;
    }
    
    var window_config = {
      layout:    'fit',
      title:     'New Visit',
      width:     800,
      height:    412,
      renderTo:  'nurse_assistant',
      scope:     this,
      modal:     true,
      constrain: true,
      items:     {
        xtype:        'form',
        layout:       'hbox',
        layoutConfig: {align:'stretch'},
        url:          form_url,
        border:       false,
        method:       form_method,
        baseParams:   {authenticity_token: FORM_AUTH_TOKEN, school_id: this.user_school_id},
        items:[{
          xtype:      'container',
          layout:     'form',
          labelAlign: 'top',
          flex:       1,
          items:      [{
            xtype:    'container',
            layout:   'auto',
            defaults: {
              xtype:  'container',
              layout: 'form',
              cls:    'ux-layout-auto-float-item',
              style:  {
                width:    '120px',
                minWidth: '120px'
              },
              defaults: {
                width:      120,
                allowBlank: false
              }
            },
            items:[{
              style:{
                paddingRight: '20px'  
              },
              items:{
                xtype:           'textfield',
                fieldLabel:      'Student ID',
                id:              'student_number',
                name:            'student_number',
                value:           student_record.student_number,
                enableKeyEvents: true,
                listeners:       {
                  scope:    this,
                  keypress: {
                    fn:    function(this_field, evt)
                    {
                      var filter_field = this_field.ownerCt.ownerCt.ownerCt.ownerCt.get(2).getBottomToolbar().getComponent('filter_student_number');
                      var val          = this_field.getValue();
                      filter_field.setValue(val);
                      filter_field.fireEvent('keypress',filter_field);
                    },
                    delay: 50
                  }
                }
              }
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Student First Name',
                id:         'first_name',
                name:       'first_name',
                value:      student_record.first_name
              }
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Student Last Name',
                id:         'last_name',
                name:       'last_name',
                value:      student_record.last_name
              }
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Contact First Name',
                id:         'contact_first_name',
                value:      student_record.contact_first_name
              }
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Contact Last Name',
                id:         'contact_last_name',
                value:      student_record.contact_last_name
              }
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Address',
                id:         'address',
                value:      student_record.address
              }
            },{
              items: new Ext.form.ComboBox({
                fieldLabel:    'Zip',
                emptyText:     'Select Zipcode...',
                allowBlank:    false,
                id:            'zip',
                store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).get('zip')}),
                typeAhead:     true,
                triggerAction: 'all',
                mode:          'local',
                lazyRender:    true,
                autoSelect:    true,
                selectOnFocus: true,
                valueField:    'id',
                displayField:  'value',
                value:         student_record.zip
              })
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Phone Number',
                id:         'phone',
                value:      student_record.phone
              }
            },{
              items:{
                fieldLabel:    'DOB',
                id:            'dob',
                xtype:         'datefield',
                emptyText:     'Select Date of Birth...',
                allowBlank:    false,
                selectOnFocus: true,
                value:         student_record.dob
              }
            },{
              items: new Ext.form.ComboBox({
                fieldLabel:    'Gender',
                emptyText:     'Select Gender...',
                allowBlank:    false,
                id:            'gender',
                store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).get('gender')}),
                typeAhead:     true,
                triggerAction: 'all',
                mode:          'local',
                lazyRender:    true,
                autoSelect:    true,
                selectOnFocus: true,
                valueField:    'id',
                displayField:  'value',
                value:         student_record.gender
              })
            },{
              items: new Ext.form.ComboBox({
                fieldLabel:    'Race',
                emptyText:     'Select Race...',
                allowBlank:    false,
                id:            'race',
                store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).get('race')}),
                typeAhead:     true,
                triggerAction: 'all',
                mode:          'local',
                lazyRender:    true,
                autoSelect:    true,
                selectOnFocus: true,
                valueField:    'id',
                displayField:  'value',
                value:         student_record.race
              })
            },{
              items: new Ext.form.ComboBox({
                fieldLabel:    'Grade',
                emptyText:     'Select Grade...',
                allowBlank:    false,
                id:            'grade',
                store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).get('grade')}),
                typeAhead:     true,
                triggerAction: 'all',
                mode:          'local',
                lazyRender:    true,
                autoSelect:    true,
                selectOnFocus: true,
                valueField:    'id',
                displayField:  'value',
                value:         student_record.grade
              })
            },{
              items:{
                xtype:      'textfield',
                fieldLabel: 'Temperature',
                id:         'temperature',
                value:      student_record.temperature
              }
            }]
          }]
        },{
          xtype:      'container',
          flex:       1,
          layout:     'form',
          labelAlign: 'top',
          style:{
            paddingRight: '5'
          },
          items:[{
            xtype:      'textarea',
            fieldLabel: 'Action Taken',
            id:         'treatment',
            anchor:     '100%',
            allowBlank: false,
            height:     72,
            value:      student_record.treatment
          },{
            xtype:  'container',
            layout: 'fit',
            height: 242,
            items:  [{
              xtype:            'grid',
              id:               'symptoms_list',
              allowBlank:       false,
              loadMask:         true,
              autoExpandColumn: 'symptom_column',
              emptyText:        '<div style="color:#000;">No symptom selected.</div>',
              store:            new Ext.data.JsonStore({fields:['name'], data:symptom_data}),
              cm:               new Ext.grid.ColumnModel({
                columns:[{
                  id:        'symptom_column',
                  header:    'Symptoms',
                  dataField: 'symptom'
                },{
                  xtype: 'xactioncolumn',
                  icon:  '/stylesheets/images/cross-circle.png',
                  listeners:{
                    scope: this,
                    click: function(this_column, this_grid, row_index, event_obj)
                    {
                      this_grid.getStore().remove(this_grid.getStore().getAt(row_index));
                    }
                  }
                }]
              }),
              tbar: {
                items: new Ext.form.ComboBox({
                  fieldLabel:    'Symptom',
                  emptyText:     'Select Symptom...',
                  allowBlank:    false,
                  id:            'symptoms',
                  store:         new Ext.data.JsonStore({fields: ['id', 'name', 'icd9_code'], data: this.init_store.getAt(0).get('symptoms')}),
                  typeAhead:     true,
                  triggerAction: 'all',
                  mode:          'local',
                  lazyRender:    true,
                  autoSelect:    true,
                  selectOnFocus: true,
                  valueField:    'id',
                  displayField:  'name',
                  scope:         this,
                  listeners:     {
                    scope:  this,
                    select: function (this_grid, record, index)
                    {
                      Ext.getCmp('symptoms_list').getStore().loadData(record.data,true);
                    }
                  }
                })
              }
            }]
          }]
        },{
          xtype:     'grid',
          id:        'student_list',
          style:     {
            padding: '5 5 5 0'
          },
          flex:       1,
          viewConfig: {
            emptyText: '<div style="color:#000;">Please enter student number.</div>'  
          },
          store:     this.student_list_store,
          loadMask:  true,
          cm:        new Ext.grid.ColumnModel({
            columns:[{
              id:        'student_first_name_column',
              header:    'First Name',
              dataField: 'first_name',
              width:     75
            },{
              id:        'student_last_name_column',
              header:    'Last Name',
              dataField: 'last_name',
              width:     75
            },{
              id:        'student_number_column',
              header:    'Number',
              dataField: 'student_number',
              width:     75
            }]
          }),
          listeners: {
            rowclick: function(this_grid, index, event)
            {
              var record = this_grid.getStore().getAt(index);
              this_grid.ownerCt.getForm().setValues({
                address:            record.get('address'),
                zip:                record.get('zip'),
                dob:                record.get('dob'),
                gender:             record.get('gender'),
                phone:              record.get('phone'),
                race:               record.get('race'),
                contact_last_name:  record.get('contact_last_name'),
                contact_first_name: record.get('contact_first_name'),
                last_name:          record.get('last_name'),
                first_name:         record.get('first_name'),
                student_number:     record.get('student_number'),
                grade:              record.get('grade') + 1
              });
            }
          },
          bbar:      {
            items: ['->', 'Student ID:', {
              xtype:           'textfield',
              id:              'filter_student_number',
              name:            'filter_student_number',
              width:           100,
              enableKeyEvents: true,
              listeners: {
                scope:    this,
                keypress: {
                  fn:    this.filter_by_student_number,
                  delay: 50
                }
              }
            },{
              text:    'Clear',
              handler: this.clear_filter,
              listeners:{
                scope:       this,
                afterrender: function(this_component)
                {
                  this.clear_filter(this_component, null);
                }
              }
            }]
          }
        }],
        listeners: {
          scope:        this,
          beforeaction: function(this_form, action)
          {
            panel_mask = new Ext.LoadMask(this_form.getEl(), {msg:"Submitting..."});
            panel_mask.show();
          },
          actionfailed: function(this_form, action)
          {
            panel_mask.hide();
          },
          actioncomplete: function(this_form, action)
          {
            this_form.ownerCt.close();
            this.main_panel_store.load({
              params:{
                filter_report_date: this.getPanel().getComponent('nurse_assistant').getTopToolbar().getComponent('visit_date').getValue(),
                school_id: this.user_school_id
              }
            });
          }
        }
      },
      buttons: [{
        text:     'Submit',
        formBind: true,
        scope:    this,
        id:       'submit_student_btn',
        handler:  function(buttonEl, eventObj)
        {
          var form                     = buttonEl.ownerCt.ownerCt.get(0).getForm();
          var symptom_store            = form.ownerCt.get(0).get(1).get(1).getComponent('symptoms_list').getStore();
          var symptom_list             = jQuery.map(symptom_store.getRange(), function(e,i){ return e.data; });
          form.baseParams.symptom_list = Ext.encode(symptom_list);
          form.submit();
        }
      },{
        text:    'Cancel',
        width:   'auto',
        handler: function(buttonEl, eventObj)
        {
          buttonEl.ownerCt.ownerCt.close();
        }
      }],
      listeners: {
        scope: this,
        close: function()
        {
          this.window_open = false;
        }
      }
    };
    
    var win = new Ext.Window(window_config);
    win.show();
  },

  clear_filter: function(button, event)
  {
    button.ownerCt.getComponent('filter_student_number').setValue('');
    button.ownerCt.ownerCt.store.filter();
  },

  filter_by_student_number:function(this_field, evt)
  {
    var val = this_field.getValue();
    val     = new RegExp(val, 'ig');
    this.student_list_store.filter([{property:'student_number', value: val}]);
  }
});

Talho.Rollcall.NurseAssistant.initialize = function(config)
{
  var na = new Talho.Rollcall.NurseAssistant(config);
  return na.getPanel();
};

Talho.ScriptManager.reg('Talho.Rollcall.NurseAssistant', Talho.Rollcall.NurseAssistant, Talho.Rollcall.NurseAssistant.initialize);