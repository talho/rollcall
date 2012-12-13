//= require rollcall/Graphing/view/AlarmQueries
//= require rollcall/Graphing/view/Alarms
//= require rollcall/Graphing/view/SearchForm
//= require rollcall/Graphing/view/Results

Ext.namespace("Talho.Rollcall.Graphing.view");

Talho.Rollcall.Graphing.view.Layout = Ext.extend(Ext.Panel, {
  id: 'graphing',
  closable: true,
  layout: 'fit',
  border: false,
  title: "Rollcall Graphing",
  
  initComponent: function () {            
    var me = this,
      findBubble = function () {
        return me;
    }
    
    this.alarm_queries = new Talho.Rollcall.Graphing.view.AlarmQueries({
      itemId: 'alarm_queries', getBubbleTarget: findBubble
    });
        
    var search_form = new Talho.Rollcall.Graphing.view.SearchForm({getBubbleTarget: findBubble});
    var results = new Talho.Rollcall.Graphing.view.Results({getBubbleTarget: this.getBubbleTarget});
        
    this.getSearchForm = function () { return search_form };
    this.getResultsPanel = function () { return results };             

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
    
    this.paging_toolbar = new Ext.PagingToolbar(
      {displayInfo: true, prependButtons: true, pageSize: 6, store: this.getResultsPanel().getResultsStore(),
       listeners: {'beforechange': function (tb, params) { this.fireEvent ('pagingparams', tb, params); return false; }, scope: this} 
      }
    );        
      
    this.export_button = new Ext.Button({text: "Export Result Set", hidden: true, scope: this, handler: function () { this.fireEvent('exportresult') }});
    this.alarm_button = new Ext.Button({text: "Create Alarm from Result Set", hidden: true, scope: this, handler: function () { this.fireEvent('saveasalarm'); }});
    this.report_button = new Ext.Button({text: "Generate Report from Result Set", hidden: true, scope: this,
      handler: function (button, firedEvent) { this.getSearchForm()._showReportMenu(button.getEl(), null) }
    });
      
    this.hidden_buttons = [this.export_button, this.alarm_button];//, this.report_button];
    
    this.graphing_panel = new Ext.Panel({id: 'graphing_panel', border: false, collapsible: false,
      region: 'center', autoScroll: true, scope: this, height: 200,
      items: [search_form, results],
      bbar: [this.paging_toolbar,        
        '->',
        new Ext.Spacer({height: 26}),
        this.export_button,
        this.alarm_button,
        this.report_button
      ],
      tbar: [
        {xtype: 'tbtext', text: 'Advanced Disease Surveillance Tool'},
        '->',              
        '-',
        this.simple_button,
        this.advanced_button
      ]      
    });
        
    this.items = [
      {id: 'graphing_layout', layout: 'border', autoScroll: true, scope: this, 
        defaults: {collapsible: false, split: true},
        items: [   
          {xtype: 'panel', region: 'south', height: 120, title: 'Alarm Queries', layout: 'fit', padding: '2px 2px 4px 2px', items: this.alarm_queries},
          {xtype: 'panel', id: 'alarms_c', itemId: 'alarms', region: 'west', title: 'Alarms', layout: 'fit', bodyStyle: 'padding: 0px',
            width: 140, minSize: 140, maxSize: 140, hideBorders: true,
            items: [new Talho.Rollcall.Graphing.view.Alarms({getBubbleTarget: findBubble})],            
          },          
          this.graphing_panel
        ]
      }
    ];   
    Talho.Rollcall.Graphing.view.Layout.superclass.initComponent.call(this);
  },    
});
