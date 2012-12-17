
Ext.namespace("Talho.Rollcall.graphing.view.filter");

Talho.Rollcall.graphing.view.filter.Basic = Ext.extend(Talho.Rollcall.ux.Filter, {
  title: 'Basic',
  
  initComponent: function () {
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
    
    this.items = [district, school, type];
        
    this.loadable = [
      {item: district, fields: ['id', 'name'], key: 'school_districts'},
      {item: school, fields: ['id', 'display_name'], key: 'schools'},
      {item: type, fields: ['id', 'value'], key: 'school_type'}
    ];
    
    this.resetable = this.items;
    
    this.getable = [];
    
    Talho.Rollcall.graphing.view.filter.Basic.superclass.initComponent.call(this);
  }
});
