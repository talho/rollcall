//= require rollcall/ADST/view/AlarmQueries
//= require rollcall/ADST/view/Alarms
//= require rollcall/ADST/view/SearchForm
//= require rollcall/ADST/view/Results

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.Layout = Ext.extend(Ext.Panel, {
  id: 'adst',
  closable: true,
  layout: 'fit',
  border: false,
  title: "Rollcall ADST",
  
  initComponent: function () {            
    var me = this,
      findBubble = function () {
        return me;
    }
    
    this.alarm_queries = new Talho.Rollcall.ADST.view.AlarmQueries({
      itemId: 'alarm_queries', getBubbleTarget: findBubble
    });
        
    var search_form = new Talho.Rollcall.ADST.view.SearchForm({getBubbleTarget: findBubble});
    var results = new Talho.Rollcall.ADST.view.Results({getBubbleTarget: this.getBubbleTarget});
    
    this.getSearchForm = function () { return search_form };
    this.getResultsPanel = function () { return results };
    
    var results_store = this.getResultsPanel().getResultsStore();       

    this.simple_button = new Ext.Button({text: 'Switch to Advanced', scope: this, 
      handler: function (button, eventObj) {
        this.getSearchForm().toggle();
        this.simple_button.hide();
        this.advanced_button.show();   
      }
    });
    
    this.advanced_button = new Ext.Button({text: 'Switch to Simple', scope: this, hidden: true,
      handler: function (button, eventObj) {
        this.getSearchForm().toggle();
        this.advanced_button.hide();
        this.simple_button.show();
      }
    });
    
    this.adst_panel = new Ext.Panel({id: 'adst_panel', border: false, collapsible: false,
      region: 'center', autoScroll: true, scope: this, height: 200,
      items: [search_form, results],
      bbar: [new Ext.PagingToolbar(
        {displayInfo: true, prependButtons: true, pageSize: 6, store: results_store }
      )],
      tbar: [
        {xtype: 'tbtext', text: 'Advanced Disease Surveillance Tool'},
        '->',              
        '-',
        this.simple_button,
        this.advanced_button
      ]      
    });
        
    this.items = [
      {id: 'adst_layout', layout: 'border', autoScroll: true, scope: this, 
        defaults: {collapsible: false, split: true},
        items: [   
          {xtype: 'panel', region: 'south', height: 120, title: 'Alarm Queries', layout: 'fit', padding: '2px 2px 4px 2px', items: this.alarm_queries},
          {xtype: 'panel', id: 'alarms_c', itemId: 'alarms', region: 'west', title: 'Alarms', layout: 'fit', bodyStyle: 'padding: 0px',
            width: 140, minSize: 140, maxSize: 140, hideBorders: true,
            items: [new Talho.Rollcall.ADST.view.Alarms({getBubbleTarget: findBubble})],            
          },          
          this.adst_panel
        ]
      }
    ];   
    Talho.Rollcall.ADST.view.Layout.superclass.initComponent.apply(this, arguments);
  }
});
