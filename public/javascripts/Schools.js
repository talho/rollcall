Ext.namespace('Talho.Rollcall');

Talho.Rollcall.Schools = Ext.extend(function(){}, {
  constructor: function(config)
  {
    this.school_store = new Ext.data.JsonStore({
      root:      'results',
      fields:    ['id', 'tea_id', 'display_name', 'gmap_lat', 'gmap_lng', 'gmap_addr', 'school_type'],
      url:       '/rollcall/schools',
      autoLoad:  true,
      listeners: {
        scope: this,
        load:  function(this_store, records){}
      }
    });

    Ext.apply(this, config);
    Ext.apply(this,
    {
      layout:   'fit',
      closable: true,
      scope:    this,
      items:[{
        layout:     'border',
        autoScroll: true,
        scope:      this,
        defaults: {
          collapsible: true,
          split:       true
        },
        items: [{
          title:     'Schools',
          region:    'west',
          layout:    'fit',
          bodyStyle: 'padding:0px',
          width:     175,
          minSize:   150,
          maxSize:   175,
          hideBorders: true,
          items:[{
            xtype: 'grid',
            store: this.school_store,
            cm:       new Ext.grid.ColumnModel({
              columns: [
                {id:'school_name', header:'School', dataIndex:'display_name'}
              ]
            }),
            viewConfig: {
              emptyText:     '<div><b style="color:#000">There are no schools</b></div>',
              enableRowBody: true
            },
            listeners: {
              scope: this,
              rowclick: this.showSchoolProfile
            }
          }]
        },{
          collapsible: false,
          region:      'center',
          autoScroll:  true,
          scope:       this,
          id:          'school_main_panel',
          itemId:      'school_main_panel'
        }]
      }]
    });
  },
  showSchoolProfile: function(grid_panel, row_index, event_obj)
  {
    var school            = grid_panel.getStore().getAt(row_index);
    var html_pad          = '<table class="alarm-tip-table"><tr><td><b>Student Daily Info:</b></td>'+
                            '<td><span>&nbsp;</span></td></tr></table>';
    var gmapPanel         = new Ext.ux.GMapPanel({zoomLevel: 12, width: 450, height: 400});
    var sch_info_tpl      = new Ext.XTemplate(
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
      height:      125,
      viewConfig:  {
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
    var student_grid_panel = new Ext.grid.GridPanel({
      forceLayout: true,
      scope:       this,
      height:      125,
      viewConfig:  {
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
        {header: 'Report Date',   sortable: true,  dataIndex: 'report_date'},
      ],
      stripeRows:  true,
      stateful:    true
    });
    var school_radio_group = new Ext.form.RadioGroup({
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


    var panel = grid_panel.ownerCt.ownerCt.getComponent('school_main_panel');
    
//    panel.add([{
//      xtype: 'container',
//      layout: 'vbox',
//      items: [{
//        xtype: 'container',
//        html: sch_info_tpl.applyTemplate(school)
//      },school_radio_group, school_grid_panel,{
//        xtype: 'container',
//        html: html_pad
//      },student_radio_group, student_grid_panel]
//    },{xtype: 'spacer', width: 10},gmapPanel]);

    panel.add({
      //title:      "School Profile for '" + panel.school_name + "'",
      layout:     'hbox',
      labelAlign: 'top',
      padding:    '5',
      //width:      810,
      items: [{
        xtype:  'container',
        layout: 'vbox',
        //width: 350, height: 400,
        items: [
          {xtype: 'container', html: sch_info_tpl.applyTemplate(school)},
          school_radio_group, school_grid_panel,
          {xtype:'container', html: html_pad},
          student_radio_group, student_grid_panel]
      },
      {xtype: 'spacer', width: 10},
      gmapPanel]
    });
    school_radio_group.addListener("change", function(group, chkd_radio )
      {
        this.getSchoolData(chkd_radio.value, panel, school_grid_panel, 'school', school.get('id'));
      },
    this);
    student_radio_group.addListener("change", function(group, chkd_radio )
      {
        this.getSchoolData(chkd_radio.value, panel, student_grid_panel, 'student', school.get('id'));
      },
    this);
    
    gmapPanel.addListener("mapready", function(obj){
      var loc = new google.maps.LatLng(school.get('gmap_lat'), school.get('gmap_lng'));
      gmapPanel.gmap.setCenter(loc);
      var addr_elems    = school.get('gmap_addr').split(",");
      var marker        = gmapPanel.addMarker(loc, school.get('display_name'), {});
      marker.info       = "<b>" + school.get('display_name') + "</b><br/>";
      marker.info      += addr_elems[0] + "<br/>" + addr_elems[1] + "<br/>" + addr_elems.slice(2).join(",");
      marker.info_popup = null;
      google.maps.event.addListener(marker, 'click', function(){
        if (marker.info_popup) {
          this.info_popup.close(gmapPanel.gmap, this);
          this.info_popup = null;
        } else {
          this.info_popup = new google.maps.InfoWindow({content: this.info});
          this.info_popup.open(gmapPanel.gmap, this);
        }
      });
    });
    panel.doLayout();
    this.getSchoolData(1, panel, school_grid_panel, 'school', school.get('id'));
    this.getSchoolData(1, panel, student_grid_panel, 'student', school.get('id'));

  },

  getSchoolData: function(month, panel, grid_panel, type, school_id)
  {
    var grid_mask = new Ext.LoadMask(grid_panel.getEl(), {msg:"Please wait...", removeMask: true});
    grid_mask.show();
    Ext.Ajax.request({
      url:     '/rollcall/get_'+type+'_data',
      method:  'POST',
      headers: {'Accept': 'application/json'},
      scope:   panel,
      params:  {
        school_id: school_id,
        time_span: month
      },
      success: function(response, options)
      {
        jsonObj = Ext.decode(response.responseText).results;
        grid_panel.store.loadData(jsonObj);
        this.doLayout();
        grid_mask.hide();
      }
    });
  }
});

Talho.Rollcall.Schools.initialize = function(config)
{
  return new Talho.Rollcall.Schools(config);
}

Talho.ScriptManager.reg('Talho.Rollcall.Schools', Talho.Rollcall.Schools, Talho.Rollcall.Schools.initialize);
