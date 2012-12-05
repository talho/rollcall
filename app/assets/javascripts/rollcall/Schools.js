//= require ext_extensions/GMapPanel

Ext.namespace('Talho.Rollcall');

Talho.Rollcall.Schools = Ext.extend(function(){}, {
  /*
  Method builds the School border layout panel, and creates the corresponding panels and stores
  @param config the config object
   */
  constructor: function(config)
  {
    this.gmap_panel     = null;
    this.listener_flag  = false;
    this.current_marker = false;
    this.school_store   = new Ext.data.JsonStore({
      root:      'results',
      fields:    ['id', 'tea_id', 'display_name', 'gmap_lat', 'gmap_lng', 'gmap_addr', 'school_type'],
      url:       '/rollcall/schools',
      autoLoad:  true,
      listeners: {
        scope: this,
        load:  function(this_store){
          var gmap_panel      = new Ext.ux.GMapPanel({zoomLevel: 12});
          var center_panel    = school_panel.getComponent('school_border').getComponent('school_main_panel');
          this.gmap_panel     = gmap_panel;
          gmap_panel.addListener("mapready", function(obj){
            var st  = this_store;
            var loc = new google.maps.LatLng(st.getAt(0).get('gmap_lat'),st.getAt(0).get('gmap_lng'));
            gmap_panel.centerMap(loc);
          }, this);
          center_panel.add({items: this.gmap_panel});
          center_panel.doLayout();

        },
        exception: function(misc){
          Ext.Msg.alert('Access', 'You are not authorized to access this feature.  Please contact TX PHIN.', function(){
            Ext.getCmp(config.id).destroy();
          }, this);
        }
      }
    });
    var sch_info_tpl   = new Ext.XTemplate(
      '<tpl for=".">',
        '<table class="alarm-tip-table">',
          '<tr>',
            '<td><b>School:</b></td>',
            '<td><span>{display_name}</span></td>',
          '</tr>',
          '<tr>',
            '<td><b>School Type:</b></td>',
            '<td><span>{school_type}</span></td>',
          '</tr>',
          '<tr>',
            '<td><b>School Daily Info:</b></td>',
            '<td><span>&nbsp;</span></td>',
          '</tr>',
        '</table>',
      '</tpl>');

    var school_grid_panel = new Ext.grid.GridPanel({
      forceLayout: true,
      scope:       this,
      height:      155,
      viewConfig:  {
        emptyText: '<div><b style="color:#000">No School Data Available</b></div>',
        forceFit: true
      },
      store: new Ext.data.JsonStore({
        autoDestroy: true,
        autoSave:    true,
        autLoad:     false,
        root:        'school_daily_infos',
        fields:      [
          {name:'id',                type:'int'},
          {name:'school_id',         type:'int'},
          {name:'report_date',       renderer: Ext.util.Format.dateRenderer('m-d-Y')},
          {name:'total_absent',      type:'int'},
          {name:'total_enrolled',    type:'int'}
        ]
      }),
      columns: [
        {header: 'Absent',      sortable: true,  dataIndex: 'total_absent'},
        {header: 'Enrolled',    sortable: true,  dataIndex: 'total_enrolled'},
        {header: 'Report Date', sortable: true,  dataIndex: 'report_date'}
      ],
      stripeRows:  true,
      stateful:    true
    });
    
    var student_grid_panel  = new Ext.grid.GridPanel({
      forceLayout: true,
      scope:       this,
      height:      155,
      viewConfig:  {
        emptyText: '<div><b style="color:#000">No Student Data Available</b></div>',
        forceFit: true
      },
      store: new Ext.data.JsonStore({
        autoDestroy: true,
        autoSave:    true,
        autLoad:     false,
        root:        'student_daily_infos',
        fields:      [
          {name:'id',                type:'int'},
          {name:'age',               type:'int'},
          {name:'confirmed_illness', type:'bool'},
          {name:'gender',            type:'string'},
          {name:'grade',             type:'int'},
          {name:'school_id',         type:'int'},
          {name:'report_date',       renderer: Ext.util.Format.dateRenderer('m-d-Y')}
        ]
      }),
      columns: [
        {header: 'Age',           sortable: true,  dataIndex: 'age'},
        {header: 'Gender',        sortable: true,  dataIndex: 'gender'},
        {header: 'Grade',         sortable: true,  dataIndex: 'grade'},
        {header: 'Confirmed',     sortable: true,  dataIndex: 'confirmed_illness'},
        {header: 'Report Date',   sortable: true,  dataIndex: 'report_date'}
      ],
      stripeRows:  true,
      stateful:    true
    });

    var school_radio_group  = new Ext.form.RadioGroup({
      fieldLabel: 'School Daily Info',
      id:         'school_radio_group',
      items: [
          {boxLabel: '1 month',  name: 'school_time', value: 1, checked: true},
          {boxLabel: '2 months', name: 'school_time', value: 2},
          {boxLabel: '3 months', name: 'school_time', value: 3}
      ],
      scope: this
    });

    var student_radio_group = new Ext.form.RadioGroup({
      fieldLabel: 'Student Daily Info',
      id:         'student_radio_group',
      items: [
          {boxLabel: '1 month',  name: 'student_time', value: 1, checked: true},
          {boxLabel: '2 months', name: 'student_time', value: 2},
          {boxLabel: '3 months', name: 'student_time', value: 3}
      ],
      scope: this
    });

    var school_list_grid = new Ext.grid.GridPanel({
      store:      this.school_store,
      loadMask:   true,
      cm:         new Ext.grid.ColumnModel({columns:[{id:'school_name',header:'School',dataIndex:'display_name',width:180,sortable:true}]}),
      viewConfig: {
        emptyText:     '<div><b style="color:#000">There are no schools</b></div>',
        enableRowBody: true
      },
      listeners: {
        scope:     this,
        rowclick:  this._showSchoolProfile
      }
    });

    var school_panel = new Ext.Panel({
      title:    config.title,
      itemId:   config.id,
      id:       config.id,
      layout:   'fit',
      closable: true,
      items:    [{
        layout:     'border',
        id:         'school_border',
        itemId:     'school_border',
        autoScroll: true,
        scope:      this,
        defaults:   {
          collapsible: true,
          split:       true
        },
        items: [{
          title:       'Schools',
          region:      'west',
          layout:      'fit',
          bodyStyle:   'padding:0px',
          width:       200,
          maxSize:     200,
          hideBorders: true,
          items:       [school_list_grid]
        },{
          hidden: true,
          region: 'east',
          title:  'School Profile',
          id:     'school_profile_panel',
          itemId: 'school_profile_panel',
          layout: 'fit',
          width:  265,
          scope:  this,
          padding: 5,
          items:  [{
            xtype:  'container',
            layout: 'vbox',
            items:  [{
              xtype:  'container',
              id:     'sch_tpl_cnt',
              itemId: 'sch_tpl_cnt',
              tpl:    sch_info_tpl,
              autoHeight: true
            },{
              xtype: 'container',
              width: 253,
              items: [school_radio_group,school_grid_panel],
              html:  '<table class="alarm-tip-table"><tr><td><b>Student Daily Info:</b></td><td><span>&nbsp;</span></td></tr></table>'
            },{
              xtype: 'container',
              width: 253,
              items: [student_radio_group,student_grid_panel]
            },{
              xtype:  'spacer',
              height: 10
            },{
              xtype:   'button',
              text:    'Generate Attendance Report',
              recipe:  'RecipeInternal::AttendanceAllRecipe',
              scope:   this,
              handler: this._showReportMessage
            },{
              xtype:  'spacer',
              height: 10
            },{
              xtype:   'button',
              text:    'Generate ILI Report',
              recipe:  'RecipeInternal::IliAllRecipe',
              scope:   this,
              handler: this._showReportMessage
            }]
          }]
        },{
          collapsible: false,
          region:      'center',
          autoScroll:  true,
          scope:       this,
          id:          'school_main_panel',
          itemId:      'school_main_panel',
          layout:      'fit'
        }]
      }]
    });

    school_radio_group.addListener('change', function(group, chkd_radio )
      {
        var id = this.school_list_grid().getSelectionModel().getSelected().get('id');
        this._getSchoolData(chkd_radio.value, this.school_grid_panel(), 'school', id);
      },
    this);

    student_radio_group.addListener('change', function(group, chkd_radio )
      {
        var id = this.school_list_grid().getSelectionModel().getSelected().get('id');
        this._getSchoolData(chkd_radio.value, this.student_grid_panel(), 'student', id);
      },
    this);

    this.returnSchoolPanel   = function(){return school_panel;};
    this.sch_info_tpl        = function(){return sch_info_tpl;};
    this.school_grid_panel   = function(){return school_grid_panel;};
    this.student_grid_panel  = function(){return student_grid_panel;};
    this.school_radio_group  = function(){return school_radio_group;};
    this.student_radio_group = function(){return student_radio_group;};
    this.school_list_grid    = function(){return school_list_grid;};

  },
  /*
  Method displays the school information by updating the sch_tpl_cnt template, also displays the google map marker for
  the school, listener function for rowclick attached to school_list_grid
  @param grid_panel the grid panel clicked
  @param row_index  the row clicked
  @param event_obj  the click event
   */
  _showSchoolProfile: function(grid_panel, row_index, event_obj)
  {
    this.grid_mask = new Ext.LoadMask(grid_panel.getEl(), {msg:"Please wait...", removeMask: true});
    this.grid_mask.show();
    var school              = grid_panel.getStore().getAt(row_index);
    var profile_panel       = grid_panel.ownerCt.ownerCt.getComponent('school_profile_panel');
    var main_panel          = grid_panel.ownerCt.ownerCt.getComponent('school_main_panel');
    profile_panel.school_id = school.get('id');
    profile_panel.setTitle('School Profile for ' + school.get('display_name'));
    if(this.current_marker){
      this.gmap_panel.removeMarker(this.current_marker);
    }
    var loc                        = new google.maps.LatLng(school.get('gmap_lat'), school.get('gmap_lng'));
    var addr_elems                 = school.get('gmap_addr').split(",");
    var marker                     = this.gmap_panel.addMarker(loc, school.get('display_name'), {});
    var gmap_panel                 = this.gmap_panel;
    marker.info                    = "<b>" + school.get('display_name') + "</b><br/>";
    marker.info                   += addr_elems[0] + "<br/>" + addr_elems[1] + "<br/>" + addr_elems.slice(2).join(",");
    marker.info_popup              = null;
    this.current_marker            = marker;
    this.gmap_panel.panTo(loc);
    google.maps.event.addListener(marker, 'click', function(){
      if(marker.info_popup) {
        this.info_popup.close(gmap_panel.gmap, this);
        this.info_popup = null;
      }else{
        this.info_popup = new google.maps.InfoWindow({content: this.info});
        this.info_popup.open(gmap_panel.gmap, this);
      }
    });
    marker.info_popup = new google.maps.InfoWindow({content: marker.info});
    marker.info_popup.open(gmap_panel.gmap, marker);
    //this.gmap_panel.ownerCt.show();
    //this.gmap_panel.ownerCt.doLayout();
    profile_panel.show();
    profile_panel.doLayout();
    this.school_grid_panel().ownerCt.ownerCt.getComponent('sch_tpl_cnt').update(school.data);
    grid_panel.ownerCt.ownerCt.doLayout();
    grid_panel.ownerCt.doLayout();
    main_panel.doLayout();
    this._getSchoolData(1, this.school_grid_panel(), 'school', school.get('id'));
    this._getSchoolData(1, this.student_grid_panel(), 'student', school.get('id'));
  },
  /*
  Method retrieves school data for the last number of months given and reloads the store with newly received data
  @param month      the number of months to retrieve
  @param grid_panel the grid_panel that will be updated
  @param type       type of data to retrieve, school or student
  @param school_id  the school id for the school we will be getting data for
   */
  _getSchoolData: function(month, grid_panel, type, school_id)
  {
    var grid_mask  = new Ext.LoadMask(grid_panel.getEl(), {msg:"Please wait...", removeMask: true});
    var grid_owner = grid_panel.ownerCt.ownerCt;
    var data_type  = type
    grid_mask.show();
    Ext.Ajax.request({
      url:     '/rollcall/get_'+type+'_data',
      method:  'POST',
      headers: {'Accept': 'application/json'},
      scope:   this,
      params:  {
        school_id: school_id,
        time_span: month
      },
      success: function(response, options)
      {
        jsonObj = Ext.decode(response.responseText).results;
        grid_panel.store.loadData(jsonObj);
        grid_owner.doLayout();
        grid_mask.hide();
        this.grid_mask.hide();
        //if(data_type == "student") this.grid_mask.hide();
      }
    });
  },
  /*
  Method displays a reports menu
  @param element   the ext element to show the menu next to
  @param school_id the school id
   */
  _showReportMenu: function(element, school_id)
  {
    var scrollMenu = new Ext.menu.Menu();
    scrollMenu.add({school_id: school_id, recipe: 'RecipeInternal::AttendanceAllRecipe', text: 'Attendance Report', handler: this._showReportMessage});
    scrollMenu.add({school_id: school_id, recipe: 'RecipeInternal::IliAllRecipe',        text: 'ILI Report',        handler: this._showReportMessage});
    scrollMenu.show(element);
  },
  /*
  Method makes an ajax request, initiating selected report, displays as callback message
  @param buttonObj the ext button pressed
  @param eventObj  the click event
   */
  _showReportMessage: function(buttonObj, eventObj)
  {
    Ext.Ajax.request({
      url:      '/rollcall/report',
      params:   {recipe_id: buttonObj.recipe, school_id: buttonObj.ownerCt.ownerCt.school_id},
      method:   'GET',
      callback: function(options, success, response)
      {
        var title = 'Generating Report';
        var msg   = 'Your report will be placed in the report portal when the system '+
                    'is done generating it. Please check the report portal in a few minutes.';
        Ext.MessageBox.show({
          title:   title,
          msg:     msg,
          buttons: Ext.MessageBox.OK,
          icon:    Ext.MessageBox.INFO
        });
      },
      failure: function(){}
    });
  }
});

Talho.Rollcall.Schools.initialize = function(config)
{
  var s = new Talho.Rollcall.Schools(config);
  return s.returnSchoolPanel();
}

Talho.ScriptManager.reg('Talho.Rollcall.Schools', Talho.Rollcall.Schools, Talho.Rollcall.Schools.initialize);
