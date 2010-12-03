Talho.ScriptManager.addInitializer('Talho.Rollcall', {js:'AjaxPanel /javascripts/rollcall/rollcall.js'});
Talho.ScriptManager.addInitializer('Talho.Rollcall.NurseAssistant', {js:'$(ext_extensions)/xActionColumn.js /javascripts/rollcall/NurseAssistant.js'});
Talho.ScriptManager.addInitializer('Talho.RollcallQuery', {
  js:'( $(ext_extensions)/Portal.js > /javascripts/rollcall/SavedQueriesPanel.js ) $(ext_extensions)/HBox.js ' +
     '( /javascripts/rollcall/MainPanel.js >  /javascripts/rollcall/SimpleSearchContainer.js ) '+
     ' /javascripts/rollcall/ReportsPanel.js ' +
     '/javascripts/rollcall/AlarmsPanel.js /javascripts/rollcall/AdvancedSearchContainer.js ' +
     '( $(ext_extensions)/Portal.js > /javascripts/rollcall/SearchResultPanel.js )'
});