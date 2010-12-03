Ext.ns("Talho.Rollcall");

Talho.Rollcall.NurseAssistant = Ext.extend(function(){}, {
  constructor: function(config){
    var store = new Ext.data.JsonStore({
      fields:['name', 'symptoms', 'action', {name:'visit_date', type:'date'}, 'id'],
      listeners: {
        scope: this,
        'load':function(){
          this.getPanel().doLayout();
        }
      }
    });

    var panel = new Ext.Panel({
      title:config.title,
      layout: 'hbox',
      itemId:config.id,
      closable: true,
      layoutConfig:{pack: 'center'},
      padding:'5 100',
      items: {
        xtype:'grid',
        title: 'Student Visits',
        frame: 'true',
        store:store,
        autoHeight:true,
        cm: new Ext.grid.ColumnModel({
          columns: [
            {id:'name_column', header:'Student Name', dataField:'name', width: 250},
            {id:'symptom_column', header:'Symptoms', dataField:'symptoms'},
            {header:'Action', dataField:'action', width:250},
            {header:'Visit Date', dataFeild:'visit_date', width: 175},
            {xtype:'xactioncolumn', items:[
              {icon:'/stylesheets/images/pencil.png'},
              {icon:'/stylesheets/images/cross-circle.png'}
              ]}
        ]}),
        autoExpandColumn:'symptom_column',
        autoExpandMax: 5000,
        bbar: new Ext.PagingToolbar({
          store:store,
          items:[
            '->',
            {xtype: 'textfield', value:'Search'},
            {text:'New', handler: this.show_new_window, scope:this}
          ]
        })
      }
    });

    this.getPanel = function(){ return panel;};

    panel.on('afterrender', function(){
      store.loadData([
        {name: 'Hampton Smith', symptoms:'Upset Stomach, Fever: 104', action:'Sent to Emergency Room', visit_date: '1/10/2010', id:'1'},
        {name: 'Norville Hollowholm', symptoms:'Headache', action:'Gave 250mg IB Profein', visit_date: '1/10/2010', id:'2'},
        {name: 'Jaxton Waldrip', symptoms:'Nausea', action:'Let rest for 10 minutes and returned to class', visit_date: '1/10/2010', id:'3'},
        {name: 'Able Waldrip', symptoms:'Sore Throat', action:'Sent Home', visit_date: '1/10/2010', id:'4'},
        {name: 'Balworn Vauxhaul', symptoms:'Sore Throat, Congestion', action:'Sent Home', visit_date: '1/10/2010', id:'5'}
      ]);
    }, this, {delay:10});
  },

  show_new_window:function(){
    var win = new Ext.Window({
      layout:'fit',
      title:'New Visit',
      width: 600,
      height: 500,
      items:{xtype: 'form',
        layout: 'hbox',
        layoutConfig:{align:'stretch'},
        items:[{
          xtype:'container',
          layout:'form',
          labelAlign:'top',
          flex:1,
          defaultType:'textfield',
          items:[
            {fieldLabel:'Student Name', anchor:'100%'},
            {fieldLabel:'Parent Name', anchor:'100%'},
            {xtype:'compositefield', items:[{xtype:'textfield', fieldLabel:'Address', flex:2}, {xtype:'textfield', fieldLabel:'Zip', flex:1}], anchor:'100%'},
            {fieldLabel:'Phone Number', anchor:'100%'},
            {xtype:'compositefield', anchor:'100%', items:[{xtype:'textfield', fieldLabel:'DOB', flex:1}, {xtype:'textfield', fieldLabel:'Gender', flex:1}, {xtype:'textfield', fieldLabel:'Race', flex:2}]},
            {fieldLabel:'Grade', anchor:'100%'},
            {xtype:'textarea', fieldLabel:'Action Taken', anchor:'100%'}
          ]
        },{
          xtype: 'container',
          flex:1,
          layout:'form',
          labelAlign:'top',
          items:[
            {xtype:'textfield', anchor:'100%', fieldLabel:'Temperature'},
            {xtype:'container', anchor:'100% -55', fieldLabel:'Symptoms', layout:'border', items:[
              {region:'north', xtype:'combo', store:['High Fever', 'Nausea', 'Headache', 'Extreme Headache'], typeAhead: true, mode:'local', forceSelection:false},
              {region:'center', xtype:'grid',
                store:new Ext.data.JsonStore({fields:['symptom'], data:[{symptom:'Diarrhea'}, {symptom:'Nausea'}, {symptom:'Upset Stomach'} ]}),
                cm: new Ext.grid.ColumnModel({columns:[
                  {id: 'symptom_column', header:'Symptom', dataField:'symptom'},
                  {xtype:'xactioncolumn', icon:'/stylesheets/images/cross-circle.png'}
                ]}),
                autoExpandColumn:'symptom_column'
              }
            ]}
          ]
        }]
      }
    });

    win.show();
  }
});

Talho.Rollcall.NurseAssistant.initialize = function(config){
  var na = new Talho.Rollcall.NurseAssistant(config);
  return na.getPanel();
};

Talho.ScriptManager.reg('Talho.Rollcall.NurseAssistant', Talho.Rollcall.NurseAssistant, Talho.Rollcall.NurseAssistant.initialize);