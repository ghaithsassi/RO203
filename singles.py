import pulp as p 
  
# Create a LP Minimization problem 
Lp_prob = p.LpProblem('singles')

n = 8

# Create problem Variables 
x = p.LpVariable.dicts("x",((i,j) for i in range(n) for j in range(n)),cat=p.LpBinary)
r = p.LpVariable.dicts("x",((i,j,k,l) for i in range(n) for j in range(n) for k in range(n) for l in range(n) ),cat=p.LpBinary)

# Objective Function 
Lp_prob += 0

grid = [[]]


Lp_prob +=