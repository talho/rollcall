Talho.ScriptManager.addInitializer('Talho.Rollcall', {js:'AjaxPanel /javascripts/rollcall/rollcall.js'});
Talho.ScriptManager.addInitializer('Talho.NurseAssistant', {js:'$(ext_extensions)/xActionColumn.js /javascripts/rollcall/nurse_assistant.js'});
Talho.ScriptManager.addInitializer('Talho.RollcallQuery', {
  js:'( $(ext_extensions)/Portal.js > /javascripts/rollcall/RollcallSavedQueriesPanel.js ) $(ext_extensions)/HBox.js ' +
     '( /javascripts/rollcall/RollcallMainPanel.js >  /javascripts/rollcall/RollcallSimpleSearchForm.js ) '+
     ' /javascripts/rollcall/RollcallReportsPanel.js ' +
     '/javascripts/rollcall/RollcallAlarmsPanel.js /javascripts/rollcall/RollcallAdvancedSearchForm.js ' +
     '( $(ext_extensions)/Portal.js > /javascripts/rollcall/RollcallSearchResultPanel.js )'
});