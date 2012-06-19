json.partial! 'application/success', success: true
json.total_results @length
json.results @students_paged