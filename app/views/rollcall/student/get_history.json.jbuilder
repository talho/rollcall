json.partial! 'application/success', success: true
json.total_results @daily_records.length
json.results @daily_records