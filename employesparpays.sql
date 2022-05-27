#### Employés par pays ####
  
  SELECT off.country, COUNT(off.country) AS nb_of_employees_per_country 
FROM offices AS off
LEFT JOIN employees AS e ON off.officeCode = e.officeCode
GROUP BY off.country
ORDER BY nb_of_employees_per_country DESC;