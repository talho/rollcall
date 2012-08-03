Ext.ns('Talho.Rollcall');

Talho.Rollcall.Users = Ext.extend(Ext.util.Observable, {
  /*
  Method builds the Rollcall User interface, creates Ext templates for roles, districts and school data for user results
   as well as the different panels for start screen, no results and server error responses.  Creates primary_panel and
   adds searchResultsContainer to the items
  @param config
   */
  constructor: function(config)
  {
    Talho.Rollcall.Users.superclass.constructor.call(this, config);
    this.RESULTS_PAGE_SIZE = 25;
    this.resultsStore      = new Ext.data.JsonStore({
      proxy:      new Ext.data.HttpProxy({url: '/rollcall/users', method: 'get'}),
      root:       'results',
      fields:     ['user_id','display_name','first_name','last_name','email','role_memberships','role_requests','photo','school_districts','schools'],
      autoLoad:   false,
      remoteSort: true,
      baseParams: {limit: this.RESULTS_PAGE_SIZE},
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
        disabled: true
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
        disabled: true
      }
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
  /*
  Method populates a menu of schools and school districts, attaches handler events, listener function for load event
  for JSONStores schoolStore and schoolDistrictStore
  @param store the ext json store
   */
  handleSchoolResults: function(store)
  {
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
        t_o.sdid = records[i].get('id');
      tbar.find("name",btn_name)[0].menu.addMenuItem(t_o);
      tbar.find("name",btn_name)[0].menu.doLayout(false, true);
    }
  },
  /*
  Method determines which panel to show, no result or results panel based on store count - listener function for load
  event attached to resultsStore
  @param store the ext store
   */
  handleResults: function(store)
  {
    if (store.getCount() < 1){
      this.searchResultsContainer.layout.setActiveItem(2); // no_results
    } else {
      this.searchResultsContainer.layout.setActiveItem(1); // show_results
    }
  },
  /*
  Method handles error results, listener function for exception for all stores
   @param proxy
   @param type
   @param action
   @param options
   @param response
   @param arg
   */
  handleError: function(proxy, type, action, options, response, arg){
    this.show_err_message(Ext.decode(response.responseText));
    this.searchResultsContainer.layout.setActiveItem(3); // search_error
  },
  /*
  Method sets selected row to be assigned either a school or a school district
  @param selModel the selected rowSelectedModel
   */
  set_edit_state: function(selModel){
    var selected_records = selModel.getSelections();
    var tbar = this.searchResults.getTopToolbar();
    tbar.find("name", "add_school_btn")[0].setDisabled(selected_records.length == 0);
    tbar.find("name", "add_school_district_btn")[0].setDisabled(selected_records.length == 0);
    if(selected_records.length > 0)
      this.c_u_id = selected_records[0].get('user_id');
  },
  /*
  Method makes an ext ajax request with userid and params to update user with, handler function for school and school
  district menu
  @param menu_item the ext menu item that was selected
  @param event     the click event
   */
  update_user: function(menu_item,event){
    menu_item.parentMenu.hide();
    var params = {};
    if(menu_item.sid != undefined)
      params = {school_id: menu_item.sid};
    else if(menu_item.sdid != undefined)
      params = {school_district_id: menu_item.sdid};
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
  },
  /*
  Method displays the error message return back from the server in an ext msg box
  @param json the json object containing the server response text
   */
  show_err_message: function(json) {
    var w = 300;
    var msg = '<b>Server Error:</b> ' + json.error + '<br>';
    if (json.exception != null) {
      w = 900;
      msg += '<b>Exception:</b> ' + json.exception + '<br><br>';
      msg += '<div style="height:400px;overflow:scroll;">';
      for (var i = 0; i < json.backtrace.length; i++)
        msg += '&nbsp;&nbsp;' + json.backtrace[i] + '<br>';
      msg += '<\div>';
    }
    Ext.Msg.show({title: 'Error', msg: msg, minWidth: w, maxWidth: w, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR});
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