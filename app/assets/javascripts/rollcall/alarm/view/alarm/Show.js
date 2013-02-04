
Ext.namespace("Talho.Rollcall.alarm.view.alarm");

Talho.Rollcall.alarm.view.alarm.Show = Ext.extend(Ext.Window, {
  layout: 'table',
  layoutConfig: {columns: 2},
  
  initComponent: function () {
    this.addEvents('alarmdelete', 'alarmignoretoggle');
    this.enableBubble(['alarmdelete', 'alarmignoretoggle']);
    
    var windowSize = Ext.getBody().getViewSize();
    this.width = windowSize.width - 40;
    this.height = windowSize.height - 40;
    this.columnWidth = (this.width - 12) / 2;
    this.rowHeight = (this.height - 62) / 2;
    
    this.store = new Ext.data.JsonStore({
      url: 'rollcall/alarms/' + this.alarm_id,      
      root: 'alarm',
      fields: ['school_name', 'school_id', 'report_date', 'reason', 'deviation', 'severity', 
        'ignore_alarm', 'school_info', 'symptom_info', 'gmap_lat', 'gmap_lng', 'gmap_addr'],
      autoLoad: true,
      listeners: {
        scope: this,
        load: this._alarmLoaded
      }
    });        
    
    var header_tpl = new Ext.XTemplate(
      '<tpl for=".">',
        '<div class="forum-wrap" style="padding: 20px;">',
          '<div class="forum-header">',
            '<span class="forum-header-title">{school_name}</span>',
            '<span class="forum-header-threads">{report_date}</span>',
          '</div>',
          '<div class="forum-divider">&nbsp;</div><br />',
          '<div>',
            '<div class="rollcall-alarm-reason">On {report_date}, {school_name} is in an alarm state because {reason}</div>',
          '</div>',
        '</div>',
      '</tpl>'
    );
    
    var school_tpl = new Ext.XTemplate(
      '<tpl for=".">',
        '<div class="forum-wrap" style="padding: 20px;">',
          '<span class="forum-header-title">Recent absentee data for {school_name}</span>',
          '<div class="forum-divider">&nbsp;</div><br /><table><tbody>',          
          '<tpl for="school_info">',
            '<tr>',
              '<td class="rollcall-alarm-show-head">{report_date}</td>',
              '<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>',
              '<td class="rollcall-alarm-show-bold">Absent: {total_absent}</td>',
              '<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>',
              '<td class="rollcall-alarm-show-bold">Enrolled: {total_enrolled}</td>',
            '</tr>',
          '</tpl></tbody></table>',
        '</div>',     
      '</tpl>'
    );
    
    var symptom_tpl = new Ext.XTemplate(
      '<tpl for=".">',
        '<div class="forum-wrap" style="padding: 20px;">',
          '<div class="forum-header">',
            '<span class="forum-header-title">Reported Symptoms for week previous to {report_date}</span>',
          '</div>',
          '<div class="forum-divider">&nbsp;</div>',
          '<tpl for="school_info">',
            '<div class="rollcall-alarm-show-row">',
              '<span class="rollcall-alarm-show-head">{name}</span>',
            '</div>',
          '</tpl>',
      '</tpl>'
    );
    
    this.gmap = new Ext.ux.GMapPanel({zoomLevel: 11, cls: 'rollcall-alarm-show-gmap', border: true});
    this.title_view = new Ext.DataView({tpl: header_tpl});
    this.school_view = new Ext.DataView({tpl: school_tpl});
    this.symptom_view = new Ext.DataView({tpl: symptom_tpl, emptyText: 'None reported'});
    
    this.defaults = {frame: false, border: false, width: this.columnWidth, height: this.rowHeight};
    
    this.items = [
      {xtype: 'panel', items: [ this.title_view ]},
      {xtype: 'panel', items: [ this.gmap ]},
      {xtype: 'panel', autoScroll: true, items: [ this.school_view ]},
      {xtype: 'panel', autoScroll: true, items: [ this.symptom_view ]}
    ];
    
    this.ignore_button = new Ext.Button({text: 'Ignore', scope: this});
    
    this.buttons = [
      this.ignore_button,
      {xtype: 'button', text: 'Delete', scope: this, handler: function () { this.fireEvent('alarmdelete', this.alarm_id); }}
    ]    
    
    Talho.Rollcall.alarm.view.alarm.Show.superclass.initComponent.call(this);
  },
  
  _alarmLoaded: function () {
    var alarm = this.store.getAt(0);
    this.school = alarm.get('school_name');
    this.report_date = alarm.get('report_date');
    this.ignored = alarm.get('ignore_alarm');
    this.location = {lat: alarm.get('gmap_lat'), lng: alarm.get('gmap_lng')};
    this.absentee_rate = alarm.get('absentee_rate');
    this.deviation = alarm.get('deviation');
    this.severity = alarm.get('severity');
    this.gmap_addr = alarm.get('gmap_addr');
    this.gmap_store = new Ext.data.JsonStore({fields: ['school_name', 'absentee_rate', 'deviation', 'severity', 'gmap_addr', 'gmap_lat', 'gmap_lng'], data: alarm.get('nearby_schools')});
    
    this.setTitle("Alarm for " + this.school + " on " + this.report_date);
    this.ignore_button.setText((this.ignored ? 'Un-Ignore' : 'Ignore'));
    this.ignore_button.setHandler(function () { 
      this.fireEvent('alarmignoretoggle', this.alarm_id, this.ignored); 
    }, this);
    
    this.title_view.bindStore(this.store);
    this.school_view.bindStore(this.store);
    this.symptom_view.bindStore(this.store);
    
    this._render_gmap_markers();
    
    this.doLayout();
  },
  
  _render_gmap_markers: function () {
    if (this.gmap.map_ready) {
      this._set_markers.call(this);
    }
    else {      
      this.gmap.on('mapready', this._set_markers, this);
    }
  },
  
  _build_gmap_marker_info: function (record) {
    var addr_elems = record.get('gmap_addr').split(','); 
       
    var marker_info = '<div class="school_marker_info">';
    marker_info += "<b>School Name: </b>" + record.get("school_name") + "<br/>";
    marker_info += '<b>Absentee Rate: </b>' + Math.round(record.get("absentee_rate")*100)/100 + '%<br/>';
    marker_info += '<b>Deviation Rate: </b>' + Math.round(record.get("deviation")*100)/100 + '%<br/>';
    marker_info += '<b>Severity: </b>' + Math.round(record.get("severity")*100)/100 + '%<br/>';    
    marker_info += '<br/><br/>';
    marker_info += addr_elems[0] + "<br/>" + addr_elems[1] + "<br/>" + addr_elems.slice(2).join(",");
    marker_info += '</div>';
    
    return marker_info;
  },
  
  _set_markers: function () {
    var color = "ffa500";
    var center = new google.maps.LatLng(this.location.lat, this.location.lng);
    this.gmap.centerMap(center);
    
    var marker = this.gmap.addStyledMarker(center, this.school_name, { color: color });        
    var record = new Ext.data.Record({school_name: this.school_name, absentee_rate: this.absentee_rate,
       deviation: this.deviation, severity: this.severity, gmap_addr: this.gmap_addr});    
    marker.info_popup = new google.maps.InfoWindow({ content: this._build_gmap_marker_info(record) });
    marker.info_popup.open(this.gmap.gmap, this);    
  }
});