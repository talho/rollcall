
Ext.namespace("Talho.Rollcall.graphing.view.filter");

Talho.Rollcall.graphing.view.filter.Basic = Ext.extend(Talho.Rollcall.ux.Filter, {
  title: 'Basic',
  
  initComponent: function () {
    this.enableBubble('activatebasic');
    
    var district = new Talho.Rollcall.ux.ComboBox({fieldLabel: 'School District', emptyText:'Select School District...',
      allowBlank: true, displayField: 'name', editable: false,      
      listeners: {
        scope: this,
        select: function(comboBox, record, index){
          this.clearOptions(comboBox.id);
        }
      }
    });
    
    var school = new Talho.Rollcall.ux.ComboBox({fieldLabel: 'School', emptyText:'Select School...', allowBlank: true, 
      displayField: 'display_name', editable: false,      
      listeners: {
        scope: this,
        select: function(comboBox, record, index){
          this.clearOptions(comboBox.id);
        }
      }
    });    
    
    var type = new Talho.Rollcall.ux.ComboBox({fieldLabel: 'School Type', emptyText: 'Select School Type...', allowBlank: true,
      editable: false,      
      listeners: {
        scope: this,
        select: function(comboBox, record, index){
          this.clearOptions(comboBox.id);
        }
      }
    });
    
    this.clearable = [district, school, type];
    
    this.items = [district, school, type];
        
    this.loadable = [
      {item: district, fields: [ {name:'id', mapping:'name'}, 'name'], key: 'school_districts'},
      {item: school, fields: [ {name:'id', mapping:'display_name'}, 'display_name'], key: 'schools'},
      {item: type, fields: [ {name:'id', mapping:'value'}, 'value'], key: 'school_type'}
    ];
    
    this.resetable = this.items;
    
    this.getable = [
      {key: 'type[]', get: function () { return [type.getValue()]; }},      
      {key: 'school_district[]', get: function () { return [district.getValue()]; }},
      {key: 'school[]', get: function () { return [school.getValue()]; }}
    ];
    
    Talho.Rollcall.graphing.view.filter.Basic.superclass.initComponent.call(this);
  },
  
  clearOptions: function (id) {
    Ext.each(this.clearable, function (item) {
      if (id != item.id) {
        item.clearValue();
      }
    });
    this.fireEvent('activatebasic');
  }
});
