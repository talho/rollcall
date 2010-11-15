Ext.namespace('Talho.ux.rollcall');

Talho.ux.rollcall.RollcallAlarmsPanel = Ext.extend(Ext.Container, {
  constructor: function(config)
  {
    Ext.applyIf(config,{
      layout:'accordion',
      layoutConfig:{
        animate:true
      },
      items: [{
        bodyStyle: 'padding: 5 0 0 5',
        html: '<div>' +
              '<a class="school_name">CEP Southeast</a>&nbsp;'+
              '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
              '<ul class="school_alerts" style="border:none">'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
              '<span>10/12</span> - <span class="absence">14.69%</span></li>'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
              '<span>10/08</span> - <span class="absence">14.98%</span></li>'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
              '<span>10/07</span> - <span class="absence">12.61%</span></li>'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
              '<span>10/06</span> - <span class="absence">11.93%</span></li>'+
              '</ul><span class="more"><a href="/schools/39">More info...</a></span>'+
              '</div>'+'<br/>'+
              '<div>' +
              '<a class="school_name">Hope Academy Charter</a>&nbsp;'+
              '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
              '<ul class="school_alerts" style="border:none">'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
              '<span>10/12</span> - <span class="absence">14.69%</span></li>'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_severe">'+
              '<span>10/08</span> - <span class="absence">10.98%</span></li>'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
              '<span>10/07</span> - <span class="absence">12.61%</span></li>'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
              '<span>10/06</span> - <span class="absence">11.93%</span></li>'+
              '</ul><span class="more"><a href="/schools/39">More info...</a></span>'+
              '</div>',
        title:'Alarm Title(1)',
        autoScroll:true,
        border:false,
        iconCls:'rollcall_alarm_icon'
      },{
        title:'Alarm Title(2)',
        html: 'some html mark up goes here',
        border:false,
        autoScroll:true,
        html: '<div>' +
              '<a class="school_name">Osborne Elementary</a>'+
              '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
              '<ul class="school_alerts" style="border:none">'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
              '<span>10/12</span> - <span class="absence">14.69%</span></li>'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
              '<span>10/06</span> - <span class="absence">11.93%</span></li>'+
              '</ul><span class="more"><a href="/schools/39">More info...</a></span>'+
              '</div>'+
              '<div>' +
              '<a class="school_name">Reach Charter</a>'+
              '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_moderate">'+
              '<ul class="school_alerts" style="border:none">'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_severe.png" class="severity" alt="Status_severe">'+
              '<span>10/12</span> - <span class="absence">14.69%</span></li>'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_moderate.png" class="severity" alt="Status_severe">'+
              '<span>10/08</span> - <span class="absence">10.98%</span></li>'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_extreme.png" class="severity" alt="Status_moderate">'+
              '<span>10/07</span> - <span class="absence">31.61%</span></li>'+
              '<li class="school_alert">'+
              '<img src="/stylesheets/images/status_extreme.png" class="severity" alt="Status_moderate">'+
              '<span>10/06</span> - <span class="absence">32.93%</span></li>'+
              '</ul><span class="more"><a href="/schools/39">More info...</a></span>'+
              '</div>',
        iconCls:'rollcall_alarm_icon'
      },{
        title:'Alarm Title(3)',
        html: 'some html mark up goes here',
        border:false,
        autoScroll:true,
        iconCls:'rollcall_alarm_icon'
      },{
        title:'Alarm Title(4)',
        html: 'some html mark up goes here',
        border:false,
        autoScroll:true,
        iconCls:'rollcall_alarm_icon'
      }]
    });
    Talho.ux.rollcall.RollcallAlarmsPanel.superclass.constructor.call(this, config);
  }
});