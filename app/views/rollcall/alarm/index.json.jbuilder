json.partial! 'application/success', success: true
json.total_results @alarms.length
json.results @alarms.flatten