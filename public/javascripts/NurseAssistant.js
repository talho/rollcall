Ext.ns('Talho.Rollcall');

Talho.Rollcall.NurseAssistant = Ext.extend(function(){}, {
  constructor: function(config)
  {
    if(window.Application.rails_environment == "cucumber"){
      this.init_date = new Date();
      this.init_date.setDate(this.init_date.getDate()- 7);
    }else this.init_date = new Date();
    this.build_detail_template();
    this.window_open    = false;
    this.user_school_id = null;
    this.init_store     = new Ext.data.JsonStore({
      root:      'options',
      fields:    ['race','age','gender','grade','symptoms','zip','total_enrolled_alpha','app_init','school_id','schools','school_name'],
      url:       '/rollcall/nurse_assistant_options',
      autoLoad:  true,
      listeners: {
        scope: this,
        load:  function(this_store, records)
        {
          if(this_store.getAt(0).get("app_init") == true) this.setup_app();
          else{
            this.main_panel.get(0).getBottomToolbar().getComponent('new_student_btn').enable();
            this.main_panel.get(0).getBottomToolbar().getComponent('settings-btn').enable();
            this.student_list_store.load();
            this.user_school_id = this_store.getAt(0).get('school_id');
            this.main_panel_store.load({params:{school_id: this.user_school_id}});
            this.main_panel.get(0).setTitle('Current Student Visits for '+this_store.getAt(0).get('school_name'));
          }
        },
        exception: function(misc){
          Ext.Msg.alert('Access', 'You are not authorized to access this feature.  Please contact TX PHIN.', function(){
            Ext.getCmp(config.id).destroy();
          }, this);
        }
      }
    });
    this.student_list_store = new Ext.data.JsonStore({
      fields:        ['first_name','last_name','student_number','phone','race','contact_first_name','contact_last_name','gender','dob','zip','address','grade','id'],
      root:          'results',
      url:           '/rollcall/students',
      autoLoad:      false,
      restful:       true,
      totalProperty: 'total_results',
      baseParams:    {start: 0, limit: 10},
      listeners:     {
        scope:      this,
        beforeload: function(this_store, options_obj)
        {
          if(this.user_school_id != null)this_store.setBaseParam('school_id', this.user_school_id);
          else this_store.setBaseParam('school_id', this.init_store.getAt(0).get('school_id'));         
        }
      }
    });
    this.student_reader = new Ext.data.JsonReader({
      root:          'results',
      totalProperty: 'total_results',
      fields: [
        {name:'id',                 type:'integer'},
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
        {name:'student_number',     type:'string'},
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
      baseParams:     {filter_report_date: this.init_date,school_id: this.user_school_id},
      listeners: {
        scope: this,
        load:  function(this_store, records){
          if(records.length != 0){
            this.main_panel.getComponent('nurse_assistant').getSelectionModel().selectRow(0);
            this.main_panel.getComponent('nurse_assistant').fireEvent('rowclick', this.main_panel.getComponent('nurse_assistant'),0);
          }else{this.build_detail_template();}
          this.init_mask.hide();
        },
        beforeload: function(this_store, options_obj)
        {
          if(this.user_school_id != null)this_store.setBaseParam('school_id', this.user_school_id);
          else this_store.setBaseParam('school_id', this.init_store.getAt(0).get('school_id'));
        }
      }
    });
    this.main_panel = new Ext.Panel({
      title:    config.title,
      itemId:   config.id,
      id:       config.id,
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
            {id:'student_number_main',    header:'Student Number',     dataIndex:'student_number', flex: 1, sortable:true},
            {id:'first_name_column_main', header:'Student First Name', dataIndex:'first_name', flex: 1, sortable:true},
            {id:'last_name_column_main',  header:'Student Last Name',  dataIndex:'last_name',  flex: 1, sortable:true},
            {id:'symptom_column_main',    header:'Symptoms',           dataIndex:'symptom', flex: 1},
            {id:'header_main',            header:'Action',             dataIndex:'treatment',  flex: 1},
            {id:'visit_date_main',        header:'Visit Date',         dataIndex:'report_date', flex: 1, sortable:true},
            {
              xtype:     'xactioncolumn',
              id:        'edit_student_entry',
              items:     [{icon:'/stylesheets/images/pencil.png'}],
              listeners: {
                scope: this,
                click: function(this_column, this_grid, row_index, event_obj)
                {
                  this.window_open = true;
                  this.student_entry_window(this.main_panel_store.getAt(row_index),'visit');
                }
              }
            },{
              xtype:     'xactioncolumn',
              id:        'delete_student_entry',
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
        autoExpandColumn: 'symptom_column_main',
        bbar: [
          {xtype: 'button',    text: 'Search', scope:this, handler: this.search_student},
          {xtype: 'textfield', id: 'search_field'},        
          {text: 'New', iconCls:'add_forum', itemId:'new_student_btn', disabled: true, handler: function(){this.student_entry_window();}, scope: this},
          {text: 'Change School', iconCls:'settings-btn', itemId: 'settings-btn', disabled: true, handler: this.setup_app, scope: this},'->',
          new Ext.PagingToolbar({store: this.main_panel_store, listeners:{refresh: function(){}}})
        ],
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
            style:         {marginRight: '-4px'},
            listeners:     {
              scope:  this,
              select: function (this_datefield, selected_date)
              {
                this.update_student_detail_panel_msg();
                this.main_panel_store.load({params:{filter_report_date: selected_date,school_id: this.user_school_id}});
              },
              afterrender: function (this_datefield){this_datefield.setValue(this.init_date);}
            }
          }]
        },
        listeners: {scope: this, rowclick: this.show_details}
      },{
        id:       'student_detail_panel',
        title:    'Student Information',
        layout:   {type:'vbox',pack:'start',align:'stretch',direction:'normal'},
        region:   'east',
        split:    true,
        width:    350,
        minWidth: 350,
        maxWidth: 350,
        padding:  5,
        items:    [{
          xtype:     'grid',
          itemdId:   'student_grid',
          id:        'student_grid',
          cls:       'student_grid',
          flex:      1,
          viewConfig: {
            emptyText: '<div style="color:#000;">There are no students for this school.</div>',
            autoFill:  true
          },
          store:     this.student_list_store,
          loadMask:  true,
          cm:        new Ext.grid.ColumnModel({
            columns:[{
              id:        'student_first_name_column_list',
              header:    'First Name',
              dataField: 'first_name',
              sortable: true
            },{
              id:        'student_last_name_column_list',
              header:    'Last Name',
              dataField: 'last_name',
              sortable:  true
            },{
              id:        'student_number_column_list',
              header:    'Number',
              dataField: 'student_number',
              sortable:  true
            },{
              xtype:     'xactioncolumn',
              id:        'edit_student_entry',
              items:     [{icon:'/stylesheets/images/pencil.png'}],
              listeners: {
                scope: this,
                click: function(this_column, this_grid, row_index, event_obj)
                {
                  this.window_open = true;
                  this.student_entry_window(this.student_list_store.getAt(row_index),'student');
                }
              }
            }]
          }),
          listeners: {scope: this, rowclick: this.show_details},
          bbar: new Ext.PagingToolbar({
            store:          this.student_list_store,
            pageSize:       10,
            scope:          this,
            displayInfo:    true,
            prependButtons: true
          }),
          tbar: ['Student ID:', {
            xtype:           'textfield',
            id:              'list_filter_student_number',
            name:            'list_filter_student_number',
            width:           100,
            enableKeyEvents: true,
            listeners:       {scope: this, keypress: {fn: this.filter_by_student_number,delay: 50}}
          },{
            text:      'Clear',
            handler:   this.clear_filter,
            listeners: {
              scope:       this,
              afterrender: function(this_component){this.clear_filter(this_component, null);}
            }
          },{
            text:    'New Student',
            scope:   this,
            handler: function(button, event){this.student_entry_window(null, 'student');}
          }]
        },{
          xtype:      'grid',
          id:         'history_grid',
          loadMask:   true,
          viewConfig: {
            emptyText: '<div style="color:#000;">History Not Available.</div>',
            autoFill:  true
          },
          flex:       1,
          store:      new Ext.data.JsonStore({
            fields:   ['report_date','symptom','treatment','temperature'],
            root:     'results',
            url:      '/rollcall/students/history',
            autoLoad: false
          }),
          style: {marginTop: '5px'},
          cm:    new Ext.grid.ColumnModel({
            columns: [
              {id:'history_report_date', header:'Report Date', dataIndex:'report_date', width: 75, sortable: true},
              {id:'history_symptoms',    header:'Symptoms',    dataIndex:'symptom'},
              {id:'history_temperature', header:'Temperature', dataIndex:'temperature', width: 75, sortable: true},
              {id:'history_action',      header:'Action',      dataIndex:'treatment', width: 75}
            ]
          })
        },{
          xtype: 'container',
          style: {marginTop: '5px'},
          id:    'student-stats',
          html:  '<div class="details"><div class="details-info"><span>Loading Data...</span></div></div>',
          flex:  1
        }]
      }],
      listeners:{
        scope: this,
        afterrender: function(this_panel)
        {
          this.init_mask = new Ext.LoadMask(this_panel.getEl(), {store: this.main_panel_store});
          this.init_mask.show();
          this_panel.doLayout();
        }
      }
    });
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
      items:     new Ext.form.ComboBox({
        fieldLabel:    'Please select your school',
        labelStyle:    'width:150px;',
        emptyText:     'Select School...',
        allowBlank:    false,
        editable:      false,
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
        listeners: {select: function(this_box, record, index){this_box.selectedIndex = index;}}
      }),
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
            this.main_panel.get(0).getBottomToolbar().getComponent('new_student_btn').enable();
            this.main_panel.get(0).getBottomToolbar().getComponent('settings-btn').enable();
            this.student_list_store.load({params:{school_id: this.user_school_id}});
            this.main_panel_store.load({params:{school_id: this.user_school_id}});
            this.main_panel.getComponent('nurse_assistant').setTitle('Current Student Visits for '+school_name);
            this.details_template.record = {};
            this.update_student_detail_panel_msg();
            buttonEl.ownerCt.ownerCt.close();
          }         
        }
      },{
        text:    'Cancel',
        width:   'auto',
        handler: function(buttonEl, eventObj){buttonEl.ownerCt.ownerCt.close();}
      }]
    });
    init_window.show();
  },
  update_student_detail_panel_msg: function()
  {
    var html_string = '<div class="details"><div class="details-info"><span>Loading Data..</span></div></div>';
    this.main_panel.getComponent('student_detail_panel').getComponent('student-stats').update(html_string);
    try{
      this.main_panel.getComponent('student_detail_panel').getComponent('history_grid').getStore().load({params: {id: this.details_template.record.get("student_id")}});
    }catch(e){
      try{
        this.main_panel.getComponent('student_detail_panel').getComponent('history_grid').getStore().load({params: {id: this.details_template.record.get("id")}});
      }catch(e){
        this.main_panel.getComponent('student_detail_panel').getComponent('history_grid').getStore().load({params:{id: null}});  
      }
    }
  },
  search_student: function(button, event)
  {
    var field_value = button.ownerCt.getComponent('search_field').getValue();
    if(field_value.length != 0){
      this.update_student_detail_panel_msg();
      this.main_panel_store.load({
        params:{search_term: field_value,school_id: this.user_school_id},
        callback: function(records, options, success)
        {
          if(records.length == 0) this.mainBody.update('<div class="x-grid-empty"><div><b style="color:#000">No student visits</b></div></div>');
        },
        scope: this.main_panel.getComponent('nurse_assistant').getView()
      });
    }  
  },
  show_details: function(grid_panel, index, event)
  {
    if(!this.window_open){
      this.init_mask = new Ext.LoadMask(grid_panel.getEl(),{
        store: this.main_panel.getComponent('student_detail_panel').getComponent('history_grid').getStore()
      });
      this.init_mask.show();
      this.details_template.panel_el  = this.main_panel.getComponent('student_detail_panel');
      this.details_template.detail_el = this.details_template.panel_el.getComponent('student-stats').getEl();
      this.details_template.record    = grid_panel.getStore().getAt(index);
      this.details_template.overwrite(this.details_template.detail_el, this.details_template.record.data);
      this.details_template.detail_el.hide();
      this.details_template.detail_el.slideIn('l', {stopFx:true,duration:.3});    
      this.main_panel.getComponent('student_detail_panel').getComponent('history_grid').getStore().load({
        params: {id: this.details_template.record.get("student_id") == null ? this.details_template.record.get("id") : this.details_template.record.get("student_id")}
      });
    }   
  },
  build_detail_template: function()
  {
    this.details_template = new Ext.XTemplate(
      '<div class="details">',
        '<tpl for=".">',
          '<div class="details-info">',
            '<div>',
              '<label> Student ID:</label><span>{student_number}</span>',
            '</div>',
            '<div class="left">',
              '<table>',
                '<tr>',
                  '<td>Phone:</td><td>{phone}</td>',
                '</tr><tr>',
                  '<td>Gender:</td><td>{gender}</td>',
                '</tr><tr>',
                  '<td>Race:</td><td>{race}</td>',
                '</tr><tr>',
                  '<td>Date of Birth: </td><td>{dob}</td>',
                '</tr>',
              '</table>',
            '</div>',
            '<div>',
              '<table>',
                '<tr>',
                  '<td>Student Name:</td><td>{first_name}&nbsp;{last_name}</td>',
                '</tr><tr>',
                  '<td>Contact Name:</td><td>{contact_first_name}&nbsp;{contact_last_name}</td>',
                '</tr><tr>',
                  '<td>Current Grade:</td><td>{grade}</td>',
                '</tr><tr>',
                  '<td valign="top">Address:</td><td>{address}<br/>{zip}</td>',
                '</tr>',
              '</table>',
            '</div>',
          '</div>',
        '</tpl>',
      '</div>'
		);
		this.details_template.compile();
  },
  student_entry_window: function()
  {
    this.window_open                          = true;
    this.student_entry_window.argv            = this.student_entry_window.arguments;
    this.student_entry_window.student_record  = {};
    this.student_entry_window.form_method     = 'POST';
    this.student_entry_window.form_url        = '/rollcall/students';
    this.student_entry_window.symptom_data    = [];
    this.student_entry_window.panel_mask      = null;
    this.student_entry_window.student_list    = null;
    this.student_entry_window.student_info_id = null;

    if(this.student_entry_window.argv.length != 0){
      if(this.student_entry_window.argv[0] != null){
        this.student_entry_window.student_record = this.student_entry_window.argv[0].copy();
        if(this.student_entry_window.argv[1] == 'visit')
          this.student_entry_window.student_record.data.id = this.student_entry_window.argv[0].get('student_id');
        this.student_entry_window.form_method       = 'PUT';
        this.student_entry_window.form_url         += '/'+this.student_entry_window.student_record.get('id');
        if(this.student_entry_window.argv[1] == 'visit'){
          this.student_entry_window.student_info_id = this.student_entry_window.argv[0].get('id');
          this.student_entry_window.symptom_data    = [];
          for(i=0;i<this.student_entry_window.student_record.get('symptom').split(',').length;i++){
            this.student_entry_window.symptom_data.push({name: this.student_entry_window.student_record.get('symptom').split(',')[i]})
          }
        }
        this.student_entry_window.student_record.data.grade += 1;
      }
    }else{
      this.student_entry_window.student_list = {
          xtype:      'grid',
          id:         'student_list',
          cls:        'student_list',
          itemId:     'student_list',
          style:      {padding: '5 5 5 0'},
          viewConfig: {
            emptyText: '<div style="color:#000;">Please enter student number.</div>',
            autoFill:  true
          },
          store:     this.student_list_store,
          loadMask:  true,
          cm:        new Ext.grid.ColumnModel({
            columns:[{
              id:        'student_list_first_name_column',
              header:    'First Name',
              dataField: 'first_name'
            },{
              id:        'student_list_last_name_column',
              header:    'Last Name',
              dataField: 'last_name'
            },{
              id:        'student_list_number_column',
              header:    'Number',
              dataField: 'student_number'
            }]
          }),
          listeners: {
            rowclick: function(this_grid, index, event)
            {
              var record = this_grid.getStore().getAt(index);
              this_grid.ownerCt.getComponent('entry_form_container').setVisible(true);
              this_grid.ownerCt.getComponent('entry_grid_container').setVisible(true);              
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
              this_grid.ownerCt.baseParams.student_id = record.id;
              this_grid.setVisible(false);
              this_grid.ownerCt.doLayout();
            }
          },
          tbar:      {
            items: ['->', 'Student ID:', {
              xtype:           'textfield',
              id:              'filter_student_number',
              name:            'filter_student_number',
              width:           100,
              enableKeyEvents: true,
              listeners:       {scope: this, keypress: {fn: this.filter_by_student_number,delay: 50}}
            },{
              text:      'Clear',
              handler:   this.clear_filter,
              listeners: {
                scope:       this,
                afterrender: function(this_component){this.clear_filter(this_component, null);}
              }
            },{
              text:    'New Student',
              handler: function(button, event){
                button.ownerCt.ownerCt.ownerCt.getComponent('entry_form_container').setVisible(true);
                button.ownerCt.ownerCt.ownerCt.getComponent('entry_grid_container').setVisible(true);
                button.ownerCt.ownerCt.ownerCt.getComponent('student_list').setVisible(false);
                button.ownerCt.ownerCt.ownerCt.doLayout();
              }
            }]
          },
          bbar: new Ext.PagingToolbar({
            store:          this.student_list_store,
            pageSize:       10,
            scope:          this,
            displayInfo:    true,
            prependButtons: true
          })
        };
    }

    this.student_entry_window.entry_form_container = {
      xtype:      'container',
      id:         'entry_form_container',
      itemId:     'entry_form_container',
      hidden:     true,
      layout:     'form',
      labelAlign: 'top',
      flex:       1,
      items:      {
        xtype:    'container',
        layout:   'auto',
        defaults: {
          xtype:    'container',
          layout:   'form',
          cls:      'ux-layout-auto-float-item',
          style:    {width: '120px',minWidth: '120px'},
          defaults: {width: 120, allowBlank: false}
        },
        items:[{
          style:{paddingRight: '20px'},
          items:{
            xtype:           'textfield',
            fieldLabel:      'Student ID',
            id:              'student_number',
            name:            'student_number',
            value:           (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.student_number
          }
        },{
          items:{
            xtype:      'textfield',
            fieldLabel: 'Student First Name',
            id:         'first_name',
            name:       'first_name',
            value:      (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.first_name
          }
        },{
          items:{
            xtype:      'textfield',
            fieldLabel: 'Student Last Name',
            id:         'last_name',
            name:       'last_name',
            value:      (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.last_name
          }
        },{
          items:{
            xtype:      'textfield',
            fieldLabel: 'Contact First Name',
            id:         'contact_first_name',
            value:      (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.contact_first_name
          }
        },{
          items:{
            xtype:      'textfield',
            fieldLabel: 'Contact Last Name',
            id:         'contact_last_name',
            value:      (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.contact_last_name
          }
        },{
          items:{
            xtype:      'textfield',
            fieldLabel: 'Address',
            id:         'address',
            value:      (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.address
          }
        },{
          items: new Ext.form.ComboBox({
            fieldLabel:    'Zip',
            emptyText:     'Select Zipcode...',
            editable:      false,
            allowBlank:    false,
            id:            'zip',
            itemId:        'zip',
            store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).data.zip}),
            typeAhead:     true,
            triggerAction: 'all',
            mode:          'local',
            lazyRender:    true,
            autoSelect:    true,
            selectOnFocus: true,
            valueField:    'id',
            displayField:  'value',
            value:         (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.zip
          })
        },{
          items:{
            xtype:      'textfield',
            fieldLabel: 'Phone Number',
            id:         'phone',
            value:      (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.phone
          }
        },{
          items:{
            fieldLabel:    'DOB',
            id:            'dob',
            xtype:         'datefield',
            emptyText:     'Select Date of Birth...',
            allowBlank:    false,
            selectOnFocus: true,
            value:         (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.dob
          }
        },{
          items: new Ext.form.ComboBox({
            fieldLabel:    'Gender',
            emptyText:     'Select Gender...',
            editable:      false,
            allowBlank:    false,
            id:            'gender',
            store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).data.gender}),
            typeAhead:     true,
            triggerAction: 'all',
            mode:          'local',
            lazyRender:    true,
            autoSelect:    true,
            selectOnFocus: true,
            valueField:    'id',
            displayField:  'value',
            value:         (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.gender
          })
        },{
          items: new Ext.form.ComboBox({
            fieldLabel:    'Race',
            emptyText:     'Select Race...',
            allowBlank:    false,
            editable:      false,
            id:            'race',
            store:         new Ext.data.JsonStore({fields: ['id', 'value'], data: this.init_store.getAt(0).data.race}),
            typeAhead:     true,
            triggerAction: 'all',
            mode:          'local',
            lazyRender:    true,
            autoSelect:    true,
            selectOnFocus: true,
            valueField:    'id',
            displayField:  'value',
            value:         (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.race
          })
        }]
      }
    };
    this.student_entry_window.entry_grid_container = {
      xtype:      'container',
      id:         'entry_grid_container',
      itemId:     'entry_grid_container',
      hidden:     true,
      flex:       1,
      layout:     'form',
      labelAlign: 'top',
      style:      {paddingRight: '5'},
      items:      [{
        xtype:      'textarea',
        fieldLabel: 'Action Taken',
        id:         'treatment',
        anchor:     '100%',
        allowBlank: false,
        height:     72,
        value:      (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.data.treatment
      },{
        xtype:  'container',
        layout: 'fit',
        height: 242,
        items:  [{
          xtype:            'grid',
          id:               'symptoms_list',
          allowBlank:       false,
          loadMask:         true,
          autoExpandColumn: 'symptom_list_column',
          emptyText:        '<div style="color:#000;">No symptom selected.</div>',
          store:            new Ext.data.JsonStore({fields:['name'], data:this.student_entry_window.symptom_data}),
          cm:               new Ext.grid.ColumnModel({
            columns:[{
              id:        'symptom_list_column',
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
              editable:      false,
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
              width:         200,
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
    };
    this.student_entry_window.window_config        = {
      layout:    'fit',
      title:     'New Visit',
      width:     550,
      height:    412,
      renderTo:  'nurse_assistant',
      scope:     this,
      modal:     true,
      constrain: true,
      items:     {
        xtype:        'form',
        layout:       'hbox',
        layoutConfig: {align:'stretch'},
        url:          this.student_entry_window.form_url,
        border:       false,
        method:       this.student_entry_window.form_method,
        baseParams:   {
          authenticity_token: FORM_AUTH_TOKEN, school_id: this.user_school_id,
          student_id: (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.get('id'),
          student_info_id: this.student_entry_window.student_info_id
        },
        items:        [this.student_entry_window.entry_form_container,this.student_entry_window.entry_grid_container],
        listeners:    {
          scope:        this,
          beforeaction: function(this_form, action)
          {
            panel_mask = new Ext.LoadMask(this_form.getEl(), {msg:"Submitting..."});
            panel_mask.show();
          },
          actionfailed: function(this_form, action){panel_mask.hide();},
          actioncomplete: function(this_form, action)
          {
            this_form.ownerCt.close();
            this.main_panel_store.load({
              params:{
                filter_report_date: this.main_panel.getComponent('nurse_assistant').getTopToolbar().getComponent('visit_date').getValue(),
                school_id: this.user_school_id
              }
            });
            this.student_list_store.load({params:{school_id: this.user_school_id}});
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
          var form = buttonEl.ownerCt.ownerCt.get(0).getForm();
          try{
            var symptom_store = form.ownerCt.get(0).get(1).get(1).getComponent('symptoms_list').getStore();
            var symptom_list  = jQuery.map(symptom_store.getRange(), function(e,i){return e.data; });
            form.baseParams.symptom_list = Ext.encode(symptom_list);
          }catch(e){}
          form.submit();
        }
      },{
        text:    'Cancel',
        width:   'auto',
        handler: function(buttonEl, eventObj){buttonEl.ownerCt.ownerCt.close();}
      }],
      listeners: {scope: this, close: function(){this.window_open = false;}}
    };

    if(this.student_entry_window.student_list != null){
      this.student_entry_window.window_config.items.items.push(this.student_entry_window.student_list);
    }else{
      this.student_entry_window.entry_form_container.hidden = false;
      if(this.student_entry_window.symptom_data.length != 0){
        this.student_entry_window.entry_grid_container.hidden = false;
        this.student_entry_window.window_config.title = "Edit Visit"
      }else{
        if(typeof this.student_entry_window.student_record.data != "undefined"){
          if(this.student_entry_window.student_record.get('id')) this.student_entry_window.window_config.title = "Edit Student";
        }else this.student_entry_window.window_config.title = "New Student";
        this.student_entry_window.window_config.items.items.splice(1);
        this.student_entry_window.window_config.width = 280;
      }
    }
    if(this.student_entry_window.student_list != null || this.student_entry_window.symptom_data.length != 0){
      this.student_entry_window.entry_form_container.items.items.push({
        items: new Ext.form.ComboBox({
          fieldLabel:    'Grade',
          emptyText:     'Select Grade...',
          allowBlank:    false,
          editable:      false,
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
          value:         (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.get('grade')
        })
      },{
        items:{
          xtype:      'textfield',
          fieldLabel: 'Temperature',
          id:         'temperature',
          value:      (typeof this.student_entry_window.student_record.data == "undefined") ? null : this.student_entry_window.student_record.get('temperature')
        }
      });
    }
    new Ext.Window(this.student_entry_window.window_config).show();
  },
  clear_filter: function(button, event)
  {
    if(button.ownerCt.getComponent('filter_student_number') == null) button.ownerCt.getComponent('list_filter_student_number').setValue('');
    else button.ownerCt.getComponent('filter_student_number').setValue('');
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
  return na.main_panel;
};
Talho.ScriptManager.reg('Talho.Rollcall.NurseAssistant', Talho.Rollcall.NurseAssistant, Talho.Rollcall.NurseAssistant.initialize);