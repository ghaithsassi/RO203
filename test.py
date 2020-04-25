# import the library pulp as p 
import pulp as p 
  
# Create a LP Minimization problem 
Lp_prob = p.LpProblem('loopy')  
  

n = 7
# Create problem Variables  
x = p.LpVariable.dicts("x",((i,j) for i in range(8) for j in range(7)),cat=p.LpBinary)   # Create a variable x >= 0
z = p.LpVariable.dicts("z",((i,j) for i in range(7) for j in range(8)),cat=p.LpBinary)   # Create a variable x >= 0
t = p.LpVariable.dicts("t",((i,j) for i in range(8) for j in range(8)),cat=p.LpBinary) 
# Objective Function 
Lp_prob += p.lpSum([x[i,j] for i in range(8) for j in range(7)]) + p.lpSum([z[i,j] for i in range(7) for j in range(8)])
# Constraints: 
row = [1,1,2,2,2,3,3,3,3,4,4,4,4,4,5,5,6,6,7,7,7]
col = [1,6,2,4,7,1,2,3,5,1,2,3,5,7,3,4,4,6,1,4,6]
val = [3,2,2,1,3,3,0,2,3,3,2,2,1,2,3,2,2,3,0,2,3]
for i in range(len(row)):
    row[i]-=1
    col[i]-=1
    Lp_prob += x[row[i],col[i]] + x[row[i]+1,col[i]] + z[row[i],col[i]] + z[row[i],col[i]+1] == val[i]

for i in range(1,7):
    for j in range(1,7):
        Lp_prob += z[i,j] + z[i-1,j] +x[i,j] + x[i,j-1]-2*t[i,j] == 0

for i in range(1,7):
    Lp_prob += z[i,0] + z[i-1,0] +x[i,0] -2*t[i,0] == 0
for i in range(1,7):
    Lp_prob += z[i,7] + z[i-1,7] + x[i,6] -2*t[i,7] == 0
for j in range(1,7):
    Lp_prob += z[0,j] + x[0,j] + x[0,j-1] -2*t[0,j]== 0
for j in range(1,7):
    Lp_prob += z[6,j] + x[7,j] + x[7,j-1] -2*t[7,j] == 0
Lp_prob += z[0,0] + x[0,0] -2*t[0,0] == 0
Lp_prob += z[0,7] + x[0,6] -2*t[0,7] == 0
Lp_prob += z[6,0] + x[7,0] -2*t[7,0] == 0
Lp_prob += z[6,7] + x[7,6] -2*t[7,7] == 0

# Display the problem 
#print(Lp_prob)
  


def next_egde(pr,st,x,z,t):
    nt = st[0],st[1]+1
    if( st[1]!=7 and nt != pr and t[nt].varValue==1 and x[st].varValue==1):
        return nt
    nt = st[0]+1,st[1]
    if( st[0] != 7 and t[nt].varValue==1 and z[st].varValue==1 and nt != pr ):
        return nt
    nt = st[0]-1,st[1]
    if( st[0] != 0 and t[nt].varValue==1 and z[nt].varValue==1 and nt != pr ):
        return nt
    nt = st[0],st[1]-1
    if( st[1] != 0 and t[nt].varValue==1 and x[nt].varValue==1 and nt != pr ):
        return nt   


while(True):
    status = Lp_prob.solve()   # Solver 
    if(p.LpStatus[status]!="Optimal"):
        print(p.LpStatus[status])
        break
    s = sum([x[i,j].varValue for i in range(8) for j in range(7)]) + sum([z[i,j].varValue for i in range(7) for j in range(8)])
    count_edges_cylcle = 0
    #find first edge
    start = (-1,-1)
    for e in t:
        if t[e] == 1:
            start = e
        break
    if(start==(-1,-1)):
        break
    current =next_egde(start,start,x,z,t)
    count_edges_cylcle+=1
    previous = start[0],start[1]
    while(current != (0,0)):
        previous,current =current, next_egde(previous,current,x,z,t)
        count_edges_cylcle+=1
    if(s==count_edges_cylcle):
        break
    s-=1
    Lp_prob += p.lpSum([x[i,j] for i in range(8) for j in range(7) if x[i,j].varValue==1]) + p.lpSum([z[i,j] for i in range(7) for j in range(8) if z[i,j].varValue==1]) <= s

# Printing the final solution 
for i in range(7):
    ch =" "
    for j in range(7):
        if(x[i,j].varValue==0):
            ch+= " - "
        else:
            ch+= "___"
        ch += " "
    print(ch)
    ch =""
    for j in range(8):
        if(z[i,j].varValue==0):
            ch +=" "
        else:
            ch +="|"
        ch += "   "
    print(ch)
ch = " "
for j in range(7):
        if(x[7,j].varValue==0):
            ch+= " - "
        else:
            ch+= "___"
        ch += " "
print(ch)

"""
status = Lp_prob.solve()   # Solver 
"""
