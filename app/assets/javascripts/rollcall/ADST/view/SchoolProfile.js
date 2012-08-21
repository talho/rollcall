//= require ext_extensions/GMapPanel

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.SchoolProfile = Ext.extend(Ext.Window, {
  layout: 'hbox',
  labelAlign: 'top',
  padding: '5',
  width: 850,

  initComponent: function () {
    this.title = "School Profile for " + this.school_name;
    var html_pad = '<table class="alarm-tip-table"><tr><td><b>Student Daily Info:</b></td><td><span>&nbsp;</span></td></tr></table>';
    var gmapPanel = new Ext.ux.GMapPanel({zoomLevel: 12, width: 450, height: 400});
    var school = this.school;
    
    gmapPanel.addListener("mapready", function (obj) {
      var loc = new google.maps.LatLng(school.gmap_lat, school.gmap_lng);
      gmapPanel.gmap.setCenter(loc);
      var addr_elems = school.gmap_addr.split(",");
      var marker = gmapPanel.addMarker(loc, school.display_name, {});
      marker.info = "<b>" + school.display_name + "</b><br/>";
      marker.info += addr_elems[0] + "<br/>" + addr_elems[1] + "<br/>" + addr_elems.slice(2).join(",");
      marker.info_popup = null;
      google.maps.event.addListener(marker, 'click', function () {
        if (marker.info_popup) {
          this.info_popup.close(gmapPanel.gmap, this);
          this.info_popup = null;
        }
        else {
          this.info_popup = new google.maps.InfoWindow({content: marker.info});
          this.info_popup.open(gmapPanel.gmap, this);
        }
      });
      marker.info_popup = new google.maps.InfoWindow({content: marker.info});
      marker.info_popup.open(gmapPanel.gmap, marker);
    });
    
    var school_info_tpl = new Ext.XTemplate(
      '<tpl for=".">',
        '<table class="alarm-tip-table">',
          '<tr>',
            '<td><b>School:</b></td>',
            '<td><span>{name}</span></td>',
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
      '</tpl>'
    );
    
    var school_grid_panel = new Ext.grid.GridPanel({
      forceLayout: true,
      scope: this,
      height: 125,
      viewConfig: {
        emptyText: '<div><b style="color:#000">No School Data Available</b></div>',
        forceFit: true
      },
      store: new Ext.data.JsonStore({
        autoDestroy: true,
        autoSave: true,
        autLoad: false,
        root: 'school_daily_infos',
        fields:      [
          {name:'id', type:'int'},
          {name:'school_id', type:'int'},
          {name:'report_date', renderer: Ext.util.Format.dateRenderer('m-d-Y')},
          {name:'total_absent', type:'int'},
          {name:'total_enrolled', type:'int'}
        ]
      }),
      columns: [
        {header: 'Absent', sortable: true, dataIndex: 'total_absent'},
        {header: 'Enrolled', sortable: true, dataIndex: 'total_enrolled'},
        {header: 'Report Date', sortable: true, dataIndex: 'report_date'}
      ],
      stripeRows:  true,
    });
    
    var student_grid_panel = new Ext.grid.GridPanel({
      forceLayout: true,
      scope: this,
      height: 125,
      viewConfig: {
        emptyText: '<div><b style="color:#000">No Student Data Available</b></div>',
        forceFit: true
      },
      store: new Ext.data.JsonStore({
        autoDestroy: true,
        autoSave: true,
        autLoad: false,
        root: 'student_daily_infos',
        fields:      [
          {name:'id', type:'int'},
          {name:'age', type:'int'},
          {name:'confirmed_illness', type:'bool'},
          {name:'gender', type:'string'},
          {name:'grade', type:'int'},
          {name:'school_id', type:'int'},
          {name:'report_date', renderer: Ext.util.Format.dateRenderer('m-d-Y')}
        ]
      }),
      columns: [
        {header: 'Age', sortable: true,  dataIndex: 'age'},
        {header: 'Gender', sortable: true, dataIndex: 'gender'},
        {header: 'Grade', sortable: true, dataIndex: 'grade'},
        {header: 'Confirmed', sortable: true, dataIndex: 'confirmed_illness'},
        {header: 'Report Date', sortable: true, dataIndex: 'report_date'}
      ],
      stripeRows: true,
      stateful: true
    });
    
    var school_radio_group = new Ext.form.RadioGroup({
      fieldLabel: 'School Daily Info',
      id: 'school_radio_group',
      items: [
        {boxLabel: '1 month', name: 'school_time', value: 1, checked: true},
        {boxLabel: '2 months', name: 'school_time', value: 2},
        {boxLabel: '3 months', name: 'school_time', value: 3}
      ],
      scope: this
    });
    
    var student_radio_group = new Ext.form.RadioGroup({
      fieldLabel: 'Student Daily Info',
      id: 'student_radio_group',
      items: [
        {boxLabel: '1 month', name: 'student_time', value: 1, checked: true},
        {boxLabel: '2 months', name: 'student_time', value: 2},
        {boxLabel: '3 months', name: 'student_time', value: 3}
      ],
      scope: this
    });
    
    this.items = [
      {xtype: 'container', layout: 'vbox', width: 350, height: 400, defaults: { xtype: 'container', width: 345}, items: [
        {html: school_info_tpl.applyTemplate(this.school)},
        {items: [school_radio_group, school_grid_panel], html: '<table class="alarm-tip-table"><tr><td><b>Student Daily Info:</b></td><td><span>&nbsp;</span></td></tr></table>'},
        {items: [student_radio_group, student_grid_panel]}
      ]},
      {xtype: 'spacer', width: 10},
      gmapPanel
    ];
    
    this.buttons = [
      {xtype: 'button', text: 'Dismiss', handler: function(){ this.close(); }, scope: this, width:'auto'}
    ];
    
    school_radio_group.addListener("change", function (group, chkd_radio) {
      this._getSchoolData(chkd_radio.value, school_grid_panel, 'school');
    }, this);
    
    student_radio_group.addListener("change", function (group, chkd_radio) {
      this._getSchoolData(chkd_radio.value, student_grid_panel, 'student');
    }, this);
    
    this.addListener("afterrender", function (obj) {
      this._getSchoolData(1, school_grid_panel, 'school');
      this._getSchoolData(1, student_grid_panel, 'student');
    }, this);
    
    Talho.Rollcall.ADST.view.SchoolProfile.superclass.initComponent.apply(this, arguments);    
  },
  
  _getSchoolData: function (month, grid_panel, type) {
    var grid_mask = new Ext.LoadMask(grid_panel.getEl(), {msg:"Please wait...", removeMask: true});    
    grid_mask.show();
    
    Ext.Ajax.request({
      url:     '/rollcall/get_' + type + '_data',
      method:  'POST',
      headers: {'Accept': 'application/json'},
      scope:   this,
      params:  {
        school_id: this.school.school_id,
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