#### Employés par département ####
  
SELECT jobTitle, COUNT(jobTitle) 
FROM employees
GROUP BY jobTitle
ORDER BY COUNT(jobTitle) DESC;