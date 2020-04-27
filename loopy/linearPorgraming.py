# import the library pulp as p 
import pulp as p 

def display_solution(grid,x,z):
    height = len(grid)
    width = len(grid[0])

    for i in range(height):
        ch1=" "
        ch2=""  
        for j in range(width):
            if(x[i,j].varValue==0):
                ch1+= ".  "
            else:
                ch1+= "___"
            ch1 += " "

            if(z[i,j].varValue==0):
                ch2 +=" "
            else:
                ch2 +="|"
            ch2 += " "+ grid[i][j] + " "
        
        if(z[i,width].varValue==0):
            ch2 +=" "
        else:
            ch2 +="|"
        
        print(ch1)
        print(ch2)
    ch1 = " "
    for j in range(width):
            if(x[height,j].varValue==0):
                ch1+= ".  "
            else:
                ch1+= "___"
            ch1 += " "
    print(ch1)

def solve(grid):
    # Create a LP problem 
    Lp_prob = p.LpProblem('loopy')
    
    height = len(grid)
    width = len(grid[0])

    # Create problem Variables  
    x = p.LpVariable.dicts("x",((i,j) for i in range(height+1) for j in range(width)),cat=p.LpBinary)   # 
    z = p.LpVariable.dicts("z",((i,j) for i in range(height) for j in range(width+1)),cat=p.LpBinary)   #
    t = p.LpVariable.dicts("t",((i,j) for i in range(height+1) for j in range(width+1)),cat=p.LpBinary) #

    # Objective Function 
    Lp_prob += p.lpSum([x[i,j] for i in range(height+1) for j in range(width)]) + p.lpSum([z[i,j] for i in range(height) for j in range(width+1)])

    for i in range(height):
        for j in range(width):
            if(grid[i][j]!=" "):
                Lp_prob += x[i,j] + x[i+1,j] + z[i,j] + z[i,j+1] == int(grid[i][j])

    for i in range(1,height):
        for j in range(1,width):
            Lp_prob += z[i,j] + z[i-1,j] +x[i,j] + x[i,j-1]-2*t[i,j] == 0


    for i in range(1,height):
        Lp_prob += z[i,0] + z[i-1,0] +x[i,0] -2*t[i,0] == 0
    for i in range(1,height):
        Lp_prob += z[i,width] + z[i-1,width] + x[i,width-1] -2*t[i,width] == 0
    for j in range(1,width):
        Lp_prob += z[0,j] + x[0,j] + x[0,j-1] -2*t[0,j]== 0
    for j in range(1,width):
        Lp_prob += z[height-1,j] + x[height,j] + x[height,j-1] -2*t[height,j] == 0

    Lp_prob += z[0,0] + x[0,0] -2*t[0,0] == 0
    Lp_prob += z[0,width] + x[0,width-1] -2*t[0,width] == 0
    Lp_prob += z[height-1,0] + x[height,0] -2*t[height,0] == 0
    Lp_prob += z[height-1,width] + x[height,width-1] -2*t[height,width] == 0


    def next_egde(previous_,current_):
        next_ = current_[0],current_[1]+1
        if( current_[1]!=width and next_ != previous_ and t[next_].varValue==1 and x[current_].varValue==1):
            return next_
        next_ = current_[0]+1,current_[1]
        if( current_[0] != height and t[next_].varValue==1 and z[current_].varValue==1 and next_ != previous_ ):
            return next_
        next_ = current_[0]-1,current_[1]
        if( current_[0] != 0 and t[next_].varValue==1 and z[next_].varValue==1 and next_ != previous_ ):
            return next_
        next_ = current_[0],current_[1]-1
        if( current_[1] != 0 and t[next_].varValue==1 and x[next_].varValue==1 and next_ != previous_ ):
            return next_
        return (-1,-1)

    while(True):
        status = Lp_prob.solve()   # Solver 
        if(p.LpStatus[status]!="Optimal"):
            print(p.LpStatus[status])
            break
        
        s = sum([x[i,j].varValue for i in range(height+1) for j in range(width)]) + sum([z[i,j].varValue for i in range(height) for j in range(width+1)])
        
        count_edges_cylcle = 0
        #find first activated edge
        start = (-1,-1)
        for e in t:
            if t[e] == 1:
                start = e
            break
        if(start==(-1,-1)):
            break
        current =next_egde(start,start)
        count_edges_cylcle+=1
        previous = start[0],start[1]
        while(current != (0,0)):
            previous,current =current, next_egde(previous,current)
            count_edges_cylcle+=1
        if(s==count_edges_cylcle):
            break
        s-=1
        Lp_prob += p.lpSum([x[i,j] for i in range(height+1) for j in range(width) if x[i,j].varValue==1]) + p.lpSum([z[i,j] for i in range(height) for j in range(width+1) if z[i,j].varValue==1]) <= s
    
    display_solution(grid,x,z)


L = []
for i in range(7):
    tmp = []
    for j in range(7):
        tmp.append(" ")
    L.append(tmp)

row = [1,1,2,2,2,3,3,3,3,4,4,4,4,4,5,5,6,6,7,7,7]
col = [1,6,2,4,7,1,2,3,5,1,2,3,5,7,3,4,4,6,1,4,6]
val = [3,2,2,1,3,3,0,2,3,3,2,2,1,2,3,2,2,3,0,2,3]

for i in range(len(row)):
    row[i]-=1
    col[i]-=1
    L[row[i]][col[i]] = str(val[i])

solve(L)