Ext.namespace("Talho.Rollcall.admin.users.view");

Talho.Rollcall.admin.users.view.Edit = Ext.extend(Ext.Panel, {
  layout: 'hbox',
  layoutConfig: {align: 'stretch'},
  border: false,
  unstyled: true,

  constructor: function(opts){
    Talho.Rollcall.admin.users.view.Edit.superclass.constructor.apply(this, arguments);
    this.addEvents('addschooldistrict', 'addschool', 'removeschooldistrict', 'removeschool');
    this.enableBubble('addschooldistrict');
    this.enableBubble('addschool');
    this.enableBubble('removeschooldistrict');
    this.enableBubble('removeschool');
  },

  getBubbleTarget: function(){
    if(!this.layoutParent){ // bubble up to the layout class way up above
      this.layoutParent = this.findParentByType('talho-rollcall-admin-users-layout');
    }
    return this.layoutParent;
  },

  initComponent: function(){
    this.districtSelector = new Ext.form.ComboBox({
      triggerAction: 'all',
      mode: 'local',
      store: this.districtStore,
      valueField: 'id',
      displayField: 'name',
      listeners: {
        scope: this,
        'select': this.loadSchools
      }
    });
    this.schoolSelector = new Ext.form.ComboBox({
      triggerAction: 'all',
      mode: 'local',
      store: new Ext.data.JsonStore({
        fields: ['id', 'display_name'],
        url: '/rollcall/schools.json',
        root: 'results',
        restful: true
      }),
      valueField: 'id',
      displayField: 'display_name'
    });

    this.districtList = new Ext.grid.GridPanel({
      store: new Ext.data.JsonStore({
        fields: ['name', 'id'],
        url: '/rollcall/users/' + this.userId + '/school_districts.json',
        restful: true,
        autoLoad: true,
        autoSave: false
      }),
      columns: [{id: 'name', dataIndex: 'name'}, {xtype: 'actioncolumn', width: 25, icon: '/assets/cross-circle.png', handler: this.removeDistrict, scope: this }],
      autoExpandColumn: 'name',
      hideHeaders: true,
      height: 300
    });
    this.schoolList = new Ext.grid.GridPanel({
      store: new Ext.data.JsonStore({
        fields: ['display_name', 'id'],
        url: '/rollcall/users/' + this.userId + '/schools.json',
        restful: true,
        autoLoad: true,
        autoSave: false
      }),
      columns: [{id: 'name', dataIndex: 'display_name'}, {xtype: 'actioncolumn', width: 25, icon: '/assets/cross-circle.png', handler: this.removeSchool, scope: this }],
      autoExpandColumn: 'name',
      hideHeaders: true,
      height: 300
    });

    this.items = [{
      xtype: 'panel',
      title: 'School Districts',
      items: [
        this.districtSelector,
        {xtype: 'button', text: 'Add this school district', handler: this.addSchoolDistrict, scope: this},
        this.districtList
      ],
      flex: 1,
      margins: '0 10 0 0'
    },
    {
      xtype: 'panel',
      title: 'Schools',
      items: [
        this.schoolSelector,
        {xtype: 'button', text: 'Add this school', handler: this.addSchool, scope: this},
        this.schoolList
      ],
      flex: 1
    }
    ];

    Talho.Rollcall.admin.users.view.Edit.superclass.initComponent.apply(this, arguments);
  },

  loadSchools: function(c, r, i){
    this.schoolSelector.getStore().load({ params: {school_district: r.get('name') } });
  },

  addSchoolDistrict: function(){
    if(this.districtSelector.getValue() != ''){
      this.fireEvent('addschooldistrict', this.userId, this.districtSelector.getValue());
      var rec = this.districtSelector.getStore().getById(this.districtSelector.getValue());
      this.districtList.getStore().loadData({id: rec.get('id'), name: rec.get('name')}, true);
      this.schoolList.getStore().load();
    }
  },

  addSchool: function(){
    if(this.schoolSelector.getValue() != ''){
      this.fireEvent('addschool', this.userId, this.schoolSelector.getValue());
      var rec = this.schoolSelector.getStore().getById(this.schoolSelector.getValue());
      this.schoolList.getStore().loadData({id: rec.get('id'), display_name: rec.get('display_name')}, true);
    }
  },

  removeDistrict: function(g, i){
    var rec = g.getStore().getAt(i);
    g.getStore().removeAt(i);
    this.fireEvent('removeschooldistrict', this.userId, rec.get('id'));
    this.schoolList.getStore().load();
  },

  removeSchool: function(g, i){
    var rec = g.getStore().getAt(i);
    g.getStore().removeAt(i);
    this.fireEvent('removeschool', this.userId, rec.get('id'));
  }
});
