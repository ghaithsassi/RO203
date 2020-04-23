import pulp as p 
  
# Create a LP Minimization problem 
Lp_prob = p.LpProblem('towers')


n= 5
# Create problem Variables  
x = p.LpVariable.dicts("x",((i,j,k) for i in range(n) for j in range(n) for k in range(1,n+1)),cat=p.LpBinary)
h = p.LpVariable.dicts("h",((i,j,l) for i in range(n) for j in range(n) for l in range(n)),cat=p.LpBinary)
v = p.LpVariable.dicts("v",((i,j,l) for i in range(n) for j in range(n) for l in range(n)),cat=p.LpBinary)

for i in range(n):
    for j in range(n):
        Lp_prob += p.lpSum(x[i,j,k] for k in range(1,n+1)) == 1
for i in range(n):
    for k in range(1,n+1):
        Lp_prob += p.lpSum(x[i,j,k] for j in range(n)) == 1
        Lp_prob += p.lpSum(x[j,i,k] for j in range(n)) == 1


