# import the library pulp as p 
import pulp as p 
  
# Create a LP Minimization problem 
Lp_prob = p.LpProblem('Problem')  
  
height = 8
width = 8

# Create problem Variables  
x = p.LpVariable.dicts("x",((i,j) for i in range(height+1) for j in range(width)),cat=p.LpBinary)   # Create a variable x >= 0
z = p.LpVariable.dicts("z",((i,j) for i in range(height) for j in range(width+1)),cat=p.LpBinary)   # Create a variable x >= 0
t = p.LpVariable.dicts("t",((i,j) for i in range(height) for j in range(width)),cat=p.LpBinary)


# Objective Function 
Lp_prob += 1


# Constraints:
h = [3,2,3,4,7,6,4,6]
v = [8,4,4,5,4,4,4,2]


for i in range(height):
    for j  in range(width):
        Lp_prob += x[i,j] + x[i+1,j] + z[i,j] + z[i,j+1]  - 2*t[i,j] == 0


for i in range(height):
    Lp_prob += p.lpSum([t[i,j] for j in range(width)]) == v[i]
for j in range(width):
    Lp_prob += p.lpSum([t[i,j] for i in range(height)]) == h[j]


# A & B

Lp_prob += x[2,0] == 1
Lp_prob += z[2,0] == 1

Lp_prob += x[8,1] == 1
Lp_prob += z[7,2] == 1

Lp_prob += x[2,4] == 1
Lp_prob += z[1,5] == 1

for i in range(height):
    if(i == 2):
        pass
    else:
        Lp_prob += z[i,0] == 0
    Lp_prob += z[i,width] == 0
for j in range(width):
    if(j == 1):
        pass
    else:
        Lp_prob += x[height,j] ==0
    Lp_prob += x[0,j] == 0 

status = Lp_prob.solve()   # Solver 
print(p.LpStatus[status])

for i in range(height):
    ch =" "
    for j in range(width):
        if(x[i,j].varValue==0):
            ch+= " - "
        else:
            ch+= "___"
        ch += " "
    print(ch)
    ch =""
    for j in range(width):
        if(z[i,j].varValue==0):
            ch +=" "
        else:
            ch +="|"
        ch += "   "
    print(ch)
ch = " "
for j in range(width):
        if(x[height,j].varValue==0):
            ch+= " - "
        else:
            ch+= "___"
        ch += " "
print(ch)
