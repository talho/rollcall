json.partial! 'application/success', success: true
json.total_results @alarm_queries.length
json.results @alarm_queries