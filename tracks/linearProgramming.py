# import the library pulp as p 
import pulp as p 
   
       
def cplexSolve() :
    fname = "./donnees.txt"
    print("hello")
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
    i=0
    while i< len(line) : 
        if i=='(' : 
            lx.append(line[i+1,i+2])
            i+=2
        else : 
            i+=1 
    line = f.readline()
    i=0
    while i< len(line) : 
        if i=='(' : 
            lz.append(line[i+1,i+2])
            i+=2
        else : 
            i+=1  
    
  
    # Create a LP Minimization problem 
    Lp_prob = p.LpProblem('tracks')  
  
    height = 8
    width = 8

    # Create problem Variables  
    x = p.LpVariable.dicts("x",((i,j) for i in range(height+1) for j in range(width)),cat=p.LpBinary)   # Create a variable x >= 0
    z = p.LpVariable.dicts("z",((i,j) for i in range(height) for j in range(width+1)),cat=p.LpBinary)   # Create a variable x >= 0
    t = p.LpVariable.dicts("t",((i,j) for i in range(height) for j in range(width)),cat=p.LpBinary)


    # Objective Function 
    Lp_prob += 1


    for i in range(height):
        for j  in range(width):
            Lp_prob += x[i,j] + x[i+1,j] + z[i,j] + z[i,j+1]  - 2*t[i,j] == 0


    for i in range(height):
        Lp_prob += p.lpSum([t[i,j] for j in range(width)]) == v[i]
        for j in range(width):
            Lp_prob += p.lpSum([t[i,j] for i in range(height)]) == h[j]
            
 
      
    for i in lx : 
        Lp_prob += x[i[0],i[1]] == 1 
        
    for i in lz : 
        Lp_prob += z[i[0],i[1]] == 1 
        
      
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
