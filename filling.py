import pulp as p 
  
# Create a LP Minimization problem 
Lp_prob = p.LpProblem('filling')

# Create problem Variables  
x = p.LpVariable.dicts("x",((i,j,k) for i in range(7) for j in range(1,10) for k in range(9)),cat=p.LpBinary) 
r = p.LpVariable.dicts("z",((i,j,k,l) for i in range(7) for j in range(9) for k in range(7) for l in range(9)),cat=p.LpBinary)

row = [1,1,2,2,2,3,3,3,3,4,4,4,4,4,5,5,6,6,7,7,7]
col = [1,6,2,4,7,1,2,3,5,1,2,3,5,7,3,4,4,6,1,4,6]
val = [3,2,2,1,3,3,0,2,3,3,2,2,1,2,3,2,2,3,0,2,3]




for i in range(len(row)):
    row[i]-=1
    col[i]-=1
    Lp_prob += x[row[i],col[i],val[i]]  == 1 
for i in range(7):
    for j in range(9):
        Lp_prob += r[i,j,i,j]  == 1
        Lp_prob += p.lpSum(x[i,j,k] for k in range(9))
Lp_prob += x[row[i],col[i]]  == val[i]
  