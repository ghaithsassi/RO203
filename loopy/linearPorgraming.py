# import the library pulp as p 
import pulp as p 
from time import time

def cplexSolve(grid):
    # Create a LP problem 
    Lp_prob = p.LpProblem('loopy',p.LpMaximize)
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
            if(grid[i][j]!=' '):
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
        if( current_[1]!=width and next_ != previous_  and x[current_].varValue==1):
            return next_
        next_ = current_[0]+1,current_[1]
        if( current_[0] != height and z[current_].varValue==1 and next_ != previous_ ):
            return next_
        next_ = current_[0]-1,current_[1]
        if( current_[0] != 0  and z[next_].varValue==1 and next_ != previous_ ):
            return next_
        next_ = current_[0],current_[1]-1
        if( current_[1] != 0 and x[next_].varValue==1 and next_ != previous_ ):
            return next_
        return (-1,-1)

    solved = False
    startTime = time()
    while(True):
        status = Lp_prob.solve()   # Solver 
        if(p.LpStatus[status]!="Optimal"):
            solved = False
            print("no solution")
            break
        
        s = sum([x[i,j].varValue for i in range(height+1) for j in range(width)]) + sum([z[i,j].varValue for i in range(height) for j in range(width+1)])
        count_edges_cylcle = 0
        #find first activated edge
        start = (-1,-1)
        for e in t:
            if t[e].varValue == 1:
                start = e
                break
        if(start==(-1,-1)):
            solved = False
            print("error")
            break
        current =next_egde(start,start)
        count_edges_cylcle+=1
        previous = start[0],start[1]
        while(current != start and current != (-1,-1) ):
            previous,current =current, next_egde(previous,current)
            count_edges_cylcle+=1
        s=int(s)
        
        if(s==count_edges_cylcle):
            solved = True
            break
        s-=1
        Lp_prob += p.lpSum([x[i,j] for i in range(height+1) for j in range(width) if x[i,j].varValue==1]) + p.lpSum([z[i,j] for i in range(height) for j in range(width+1) if z[i,j].varValue==1]) <= s
    endTime = time()
    solution = [[],[],]

    for i in range(height+1):
        tmp = []
        for j in range(width):
            if(x[i,j].varValue == 1):
                tmp.append(True)
            else:
                tmp.append(False)
        solution[0].append(tmp)
    
    for i in range(height):
        tmp = []
        for j in range(width+1):
            if(z[i,j].varValue == 1):
                tmp.append(True)
            else:
                tmp.append(False)
        solution[1].append(tmp)


    return solved,solution,(endTime-startTime)
    
        




