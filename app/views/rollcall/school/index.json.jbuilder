json.partial! 'application/success', success: true
json.total_results @results.length
json.results @results