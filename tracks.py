# import the library pulp as p 
import pulp as p 
   
       
def tracks() :
    fname = "donnees.txt"

    f= open(fname, 'r') 
    line = f.readline()
    h=[]
    v=[]
    lx=[]
    lz=[]

    for i in line :
        if i not in [',',']',' ','h','=','[','\n'] :
            h.append(int(i))
    line = f.readline()
    for i in line :
        if i not in [',',']',' ','v','=','[','\n'] :
            v.append(int(i))
    line = f.readline()

    lx=[(2,0),(8,1),(2,4)]
    lz=[(2,0),(7,2),(1,5)]

    A = (2,0)
    B = (1,7)
    
    # Create a LP Minimization problem 
    Lp_prob = p.LpProblem('tracks',p.LpMaximize)  
  
    height = 8
    width = 8

    # Create problem Variables  
    x = p.LpVariable.dicts("x",((i,j) for i in range(height+1) for j in range(width)),cat=p.LpBinary)   # Create a variable x >= 0
    z = p.LpVariable.dicts("z",((i,j) for i in range(height) for j in range(width+1)),cat=p.LpBinary)   # Create a variable x >= 0
    t = p.LpVariable.dicts("t",((i,j) for i in range(height) for j in range(width)),cat=p.LpBinary)


    # Objective Function 
    Lp_prob += p.lpSum([x[i,j] for i in range(height+1) for j in range(width)]) + p.lpSum([z[i,j] for i in range(height) for j in range(width+1)])


    for i in range(height):
        for j  in range(width):
            Lp_prob += x[i,j] + x[i+1,j] + z[i,j] + z[i,j+1]  - 2*t[i,j] == 0


    for i in range(height):
        Lp_prob += p.lpSum([t[i,j] for j in range(width)]) == v[i]
        for j in range(width):
            Lp_prob += p.lpSum([t[i,j] for i in range(height)]) == h[j]
            
 
      
    for i in lx : 
        Lp_prob += x[i] == 1 
        
    for i in lz : 
        Lp_prob += z[i] == 1

    fixedX = set(lx)
    fixedZ = set(lz)
      
    for i in range(height):
        if( (i,0) in fixedZ ):
            pass
        else:
            Lp_prob += z[i,0] == 0
        if( (i,width) in fixedZ ):
            pass
        else:
            Lp_prob += z[i,width] == 0
    for j in range(width):
        if((0,j) in fixedX):
            pass
        else:
            Lp_prob += x[0,j] == 0 
    
        if( (height,j) in fixedX):
            pass
        else:
            Lp_prob += x[height,j] ==0
   
    def next_node(previous_,current_):
        next_ = current_[0],current_[1]+1
        if( current_[1] < width-1 and next_ != previous_  and z[next_].varValue==1):
            return next_
        next_ = current_[0]+1,current_[1]
        if( current_[0] < height-1 and x[next_].varValue==1 and next_ != previous_ ):
            return next_
        next_ = current_[0]-1,current_[1]
        if( current_[0] != 0  and x[current_].varValue==1 and next_ != previous_ ):
            return next_
        next_ = current_[0],current_[1]-1
        if( current_[1] != 0 and z[current_].varValue==1 and next_ != previous_ ):
            return next_
        return (-1,-1)
    status = Lp_prob.solve()   # Solver 
    print(p.LpStatus[status])
    a=next_node(A,A)
    b = a
    a = next_node(b,a)
    print(a)
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


tracks()