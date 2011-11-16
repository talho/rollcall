Ext.ns('Talho.Rollcall');

Talho.Rollcall.Users = Ext.extend(Ext.util.Observable, {
  constructor: function(config)
  {
    Talho.Rollcall.Users.superclass.constructor.call(this, config);
    this.RESULTS_PAGE_SIZE = 10;
    this.resultsStore      = new Ext.data.JsonStore({
      proxy:      new Ext.data.HttpProxy({url: '/rollcall/users', method: 'get'}),
      root:       'results',
      fields:     ['user_id','display_name','first_name','last_name','email','role_memberships','role_requests','photo','school_districts','schools'],
      autoLoad:   false,
      remoteSort: true,
      baseParams: {limit: this.RESULTS_PAGE_SIZE, authenticity_token: FORM_AUTH_TOKEN},
      listeners:  {
        scope:     this,
        load:      this.handleResults,
        exception: this.handleError
      }
    });
    this.schoolDistrictStore = new Ext.data.JsonStore({
      proxy: new Ext.data.HttpProxy({url: '/rollcall/get_user_school_districts', method: 'get'}),
      root:  'results',
      fields:     ['id','name'],
      autoLoad:   false,
      remoteSort: true,
      storeId:    'school_district_store',
      baseParams: {authenticity_token: FORM_AUTH_TOKEN},
      listeners:  {
        scope:     this,
        load:      this.handleSchoolResults,
        exception: this.handleError
      }
    });
    this.schoolStore = new Ext.data.JsonStore({
      proxy:      new Ext.data.HttpProxy({url: '/rollcall/schools', method: 'get'}),
      root:       'results',
      fields:     ['id','display_name'],
      autoLoad:   false,
      remoteSort: true,
      storeId:    'school_store',
      baseParams: {authenticity_token: FORM_AUTH_TOKEN},
      listeners:  {
        scope:     this,
        load:      this.handleSchoolResults,
        exception: this.handleError
      }
    });
    this.resultsStore.setDefaultSort('last_name', 'asc');    // tell ext what the initial dataset will look like

    this.nameColTemplate = new Ext.XTemplate(
      '<div style="float: left; height: 60px; width: 60px;"><img src="{photo}"></div>',
      '<div style="float: left; margin-left: 15px; width: 205px;">',
        '<span style="white-space:normal; font-weight: bold; font-size: 150%;">{display_name}</span><br/ >',
        '<tpl if="(first_name +\' \' + last_name) != display_name">({first_name} {last_name})<br /></tpl>',
      '{email}</div>'
    );

    this.rolesColTemplate = new Ext.XTemplate(
      '<tpl for="role_memberships"><p>{.}</p></tpl>',
      '<tpl if="role_requests.length &gt; 0"><br>Pending:<br></tpl>',
      '<tpl for="role_requests"><p><i>{.}</i></p></tpl>'
    );

    this.districtColTemplate = new Ext.XTemplate(
      '<tpl for="school_districts">',
        '<p class="x-tpl-district-name"><span>{name}</span></p>',
        '<p class="x-tpl-circle-icon" onclick="Ext.getCmp(\'rollcall_users\').remove_school_district_event({parent.user_id},{id});"></p>',
      '</tpl>',
      '<tpl if="school_districts.length &lt; 1">',
        '<p class="x-tpl-district-name"><span>None</span></p>',
      '</tpl>'
    );
    this.schoolColTemplate = new Ext.XTemplate(
      '<tpl for="schools">',
        '<p class="x-tpl-school-name"><span>{display_name}</span></p>',
        '<p class="x-tpl-circle-icon" onclick="Ext.getCmp(\'rollcall_users\').remove_school_event({parent.user_id},{id});"></p>',
      '</tpl>',
      '<tpl if="schools.length &lt; 1">',
        '<p class="x-tpl-school-name"><span>None</span></p>',
      '</tpl>'
    );

    this.startScreen = new Ext.Panel ({
      html: '<div style=" padding: 20px;"><span style="font-size: 200%;">Rollcall Users</span><br/>Loading...</div>'
    });

    this.noResultsScreen = new Ext.Panel ({
      html: '<div style=" padding: 20px;"><span style="font-size: 200%;">No Results</span><br/>No Rollcall users.</div>'
    });

    this.serverError = new Ext.Panel ({
      html: '<div style="padding: 20px;"><span style="font-size: 200%;">Server Error</span><br/>There was an error communicating with the server.<br/ >If the problem persists, please contact an administrator.</div>'
    });

    var admin_mode_buttons = [
      {xtype: 'tbspacer', width: 25},
      { 
        text: 'Add School',
        iconCls: 'add_school_btn',
        iconAlign: 'left',
        name: 'add_school_btn',
        enableToggle : undefined,
        menu : {
          boxMinHeight: 300,
          items:  []
        },
        scope: this,
        disabled: true,
        handler: function(){
//        Application.fireEvent('opentab', {title: 'Add User', id: 'add_new_user', initializer: 'Talho.AddUser'});
        }
      },
      {
        text: 'Add School District',
        iconCls: 'add_school_district_btn',
        iconAlign: 'left',
        name: 'add_school_district_btn',
        enableToggle : undefined,
        menu : {
          boxMinHeight: 300,
          items:  []
        },
        scope: this,
        disabled: true,
        handler: function(){
//        var selected_records = this.searchResults.getSelectionModel().getSelections();
//        Ext.each(selected_records, function(e,i){ this.openEditUserTab(e) }, this);
      }}//,
//      {text: 'Delete User', name: 'delete_btn', disabled: true, scope: this, handler: function(){
//        var selected_records = this.searchResults.getSelectionModel().getSelections();
//        if (selected_records.length == 0) return;
//        Ext.Msg.confirm("Confirm User Deletion", "Are you sure you wish to delete " + selected_records.length + " users?",
//          function(id){
//            if (id != "yes") return;
//            var delete_params = new Object;
//            Ext.each(selected_records, function(record,i){ delete_params["users[user_ids][]"] = record.get('user_id'); });
//            var json_auth = Ext.apply({'authenticity_token': FORM_AUTH_TOKEN}, delete_params);
//            Ext.Ajax.request({ url: "/users/deactivate.json", method: "POST", params: json_auth,
//              success: function(response){this.ajax_success_cb(response)},
//              failure: function(response){this.ajax_err_cb(response)}, scope: this });
//          }, this);
//      }}
    ];
    
    this.searchResults = new Ext.grid.GridPanel({
      cls: 'rollcall_users_grid',
      layout: 'hbox',
      store: this.resultsStore,
      colModel: new Ext.grid.ColumnModel({
        columns: [
          { id: 'user', dataIndex: 'first_name', header: 'Search Results', sortable: true, width: 300, xtype: 'templatecolumn', tpl: this.nameColTemplate },
          { id: 'roles', dataIndex: 'role_memberships', header: 'Roles', sortable: false, width: 300, xtype: 'templatecolumn', tpl: this.rolesColTemplate },
          { id: 'districts', dataIndex: 'school_districts', header: 'Districts', sortable: false, width: 150, xtype: 'templatecolumn', tpl: this.districtColTemplate},
          { id: 'schools', dataIndex: 'schools', header: 'Schools', sortable: false, width: 250, xtype: 'templatecolumn', tpl: this.schoolColTemplate}
        ]
      }),
      selModel: new Ext.grid.RowSelectionModel({
        listeners: {scope:this, selectionchange: this.set_edit_state}
      }),
      tbar: new Ext.PagingToolbar({
        pageSize: this.RESULTS_PAGE_SIZE,
        store: this.resultsStore,
        displayInfo: true,
        displayMsg: 'Displaying results {0} - {1} of {2}',
        emptyMsg: "No results",
        items: admin_mode_buttons,
        listeners: {
          scope: this,
          afterrender: function(comp){
            this.schoolDistrictStore.load();
            this.schoolStore.load();
          }
        }
      })
    });

    this.searchResultsContainer = new Ext.Panel({
      region: 'center',
      layout: 'card',
      activeItem: 0,
      frame: false,
      border: true,
      bodyBorder: false,
      margins: '5 5 5 0',
      padding: '0',
      items: [
        this.startScreen,
        this.searchResults,
        this.noResultsScreen,
        this.serverError
      ],
      listeners: {
        scope:       this,
        afterrender: function(cmp){
          this.searchingLoadMask = new Ext.LoadMask(cmp.getEl(), { msg:"Searching...", store: this.resultsStore });
          var searchData                         = [];
          var roleIds                            = [];
          var jurisdictionIds                    = [];
          searchData['with[role_ids][]']         = roleIds;
          searchData['with[jurisdiction_ids][]'] = jurisdictionIds;
          searchData['dir']                      = 'ASC';
          searchData['sort']                     = 'last_name';
          searchData['format']                   = 'json';
          for (var derp in searchData ){
            this.resultsStore.setBaseParam( derp, searchData[derp] );
          }
          this.resultsStore.load();
        }
      }
    });

    this.primary_panel = new Ext.Panel({
      layout:'border',
      id: config.id,
      itemId: config.id,
      closable: true,
      items: [
        this.searchResultsContainer
      ],
      title: config.title,
      remove_school_district_event: function(row_id, id){
        Ext.Ajax.request({
          url:      '/rollcall/users/'+row_id+'.json',
          params:   {school_district_id: id},
          method:   'DELETE',
          scope:    this,
          callback: function(options,success,response){
            this.getComponent(0).getComponent(1).getStore().load();
          }
        });
        this.initialConfig.scope.searchingLoadMask.show();
      },
      remove_school_event: function(row_id, id){
        Ext.Ajax.request({
          url:      '/rollcall/users/'+row_id+'.json',
          params:   {school_id: id},
          method:   'DELETE',
          scope:    this,
          callback: function(options,success,response){
            this.getComponent(0).getComponent(1).getStore().load();
          }
        });
        this.initialConfig.scope.searchingLoadMask.show();
      },
      scope: this
    });

    this.getPanel = function(){
      return this.primary_panel;
    };
  },
  handleSchoolResults: function(store){
    var records  = store.getRange();
    var tbar     = this.searchResults.getTopToolbar();
    var btn_name = '';
    var key      = '';
    if(store.fields.containsKey('display_name')){
      btn_name = 'add_school_btn';
      key      = 'display_name';
    }else if(store.fields.containsKey('name')){
      btn_name = 'add_school_district_btn';
      key      = 'name';
    }
    for(i=0;i < records.length; i++){
      t_o = {
        text: records[i].get(key),
        handler: this.update_user,
        scope: this
      };
      if(btn_name == 'add_school_btn')
        t_o.sid = records[i].get('id');
      else if(btn_name == 'add_school_district_btn')
        t_o.sdid = records[i].get('id')
      tbar.find("name",btn_name)[0].menu.addMenuItem(t_o);
      tbar.find("name",btn_name)[0].menu.doLayout(false, true);
    }
  },
  handleResults: function(store){
    if (store.getCount() < 1){
      this.searchResultsContainer.layout.setActiveItem(2); // no_results
    } else {
      this.searchResultsContainer.layout.setActiveItem(1); // show_results
    }
  },
  handleError: function(proxy, type, action, options, response, arg){
    this.show_err_message(Ext.decode(response.responseText));
    this.searchResultsContainer.layout.setActiveItem(3); // search_error
  },
  set_edit_state: function(selModel){
    var selected_records = selModel.getSelections();
    var tbar = this.searchResults.getTopToolbar();
    tbar.find("name", "add_school_btn")[0].setDisabled(selected_records.length == 0);
    tbar.find("name", "add_school_district_btn")[0].setDisabled(selected_records.length == 0);
    if(selected_records.length > 0)
      this.c_u_id = selected_records[0].get('user_id');
  },
  update_user: function(menu_item,event){
    menu_item.parentMenu.hide();
    var params = {};
    if(menu_item.sid != undefined)
      params = {school_id: menu_item.sid};
    else if(menu_item.sdid != undefined)
      params = {school_district_id: menu_item.sdid}
    Ext.Ajax.request({
      url:      '/rollcall/users/'+this.c_u_id+'.json',
      params:   params,
      method:   'PUT',
      scope:    this,
      callback: function(options,success,response){
        this.searchResults.getStore().load();
      }
    });
    this.searchingLoadMask.show();
  }
});

/**
 * Initializer for the Rollcall.Users object. Returns a panel
 */
Talho.Rollcall.Users.initialize = function(config){
    this.rollcall_user_panel = new Talho.Rollcall.Users(config);
    return this.rollcall_user_panel.getPanel();
};

Talho.ScriptManager.reg('Talho.Rollcall.Users', Talho.Rollcall.Users, Talho.Rollcall.Users.initialize);