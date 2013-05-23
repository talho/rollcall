//= require_tree ./view

Ext.ns('Talho.Rollcall.admin.users');

Talho.Rollcall.admin.users.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function(){
    var layout = new Talho.Rollcall.admin.users.view.Layout();

    this.getPanel = function(){
      return layout;
    }

    this.districtStore = new Ext.data.JsonStore({
      fields: ['id', 'name'],
      url: '/rollcall/users/available_school_districts.json',
      root: 'results',
      autoLoad: true,
      restfull: true
    });

    Talho.Rollcall.admin.users.Controller.superclass.constructor.call(this);

    layout.on('userselect', this.userSelected, this);
    layout.on('addschooldistrict', this.addSchoolDistrict, this);
    layout.on('addschool', this.addSchool, this);
    layout.on('removeschooldistrict', this.removeSchoolDistrict, this);
    layout.on('removeschool', this.removeSchool, this);
  },

  userSelected: function(id, name){
    var holder = this.getPanel().editHolder;
    holder.removeAll();
    holder.add(new Talho.Rollcall.admin.users.view.Edit({ districtStore: this.districtStore, userId: id }));
    holder.doLayout();
  },

  addSchoolDistrict: function(userId, districtId){
    Ext.Ajax.request({
      url: '/rollcall/users/' + userId + '.json',
      method: 'PUT',
      params: {school_district_id: districtId}
    });
  },

  addSchool: function(userId, schoolId){
    Ext.Ajax.request({
      url: '/rollcall/users/' + userId + '.json',
      method: 'PUT',
      params: {school_id: schoolId}
    });
  },

  removeSchoolDistrict: function(userId, districtId){
    Ext.Ajax.request({
      url: '/rollcall/users/' + userId + '.json',
      method: 'DELETE',
      params: {school_district_id: districtId}
    });
  },

  removeSchool: function(userId, schoolId){
    Ext.Ajax.request({
      url: '/rollcall/users/' + userId + '.json',
      method: 'DELETE',
      params: {school_id: schoolId}
    });
  }
});

Talho.ScriptManager.reg('Talho.Rollcall.Admin.Users', Talho.Rollcall.admin.users.Controller, function(config){
    var cont = new Talho.Rollcall.admin.users.Controller();
    return cont.getPanel();
});
