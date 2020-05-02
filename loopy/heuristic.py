import sympy as syp
from sympy.logic.boolalg import to_cnf
from time import time
def none(L):
    ans = syp.true
    for e in L:
        ans = ans & ~e
    return ans
def atLeastOne(L):
    ans= syp.false
    for e in L:
        ans = ans | e
    return ans
def atMostOne(L):
    ans = syp.true
    for i in range(len(L)-1):
        for j in range(i+1,len(L)):
            ans = ans & (~L[i] | ~L[j] )
    return ans
def exactlyOne(L):
    return atLeastOne(L) & atMostOne(L)
def exactlyOneNot(L):
    aux = []
    for e in L:
        aux.append(~e)
    return exactlyOne(aux)
def exactlyTwo(L):
    ans = syp.false
    for i in range(len(L)-1):
        for j in range(i+1,len(L)):
            tmp = L[i]&L[j]
            for k in range(len(L)):
                if( k != i and k != j):
                    tmp = tmp  & ~L[k]
            ans = ans | tmp
    return ans   
def heuristicSolve(grid):
    height = len(grid)
    width = len(grid[0])

    xRow = height+1
    xCol = width

    zRow = height
    zCol = width+1

    x = []
    z = []
    for i in range(xRow):
        tmp = []
        for j in range(xCol):
            e = syp.symbols("x"+str(i)+"_"+str(j))
            tmp.append(e)
        x.append(tmp)
    for i in range(zRow):
        tmp =[]
        for j in range(zCol):
            e = syp.symbols("z"+str(i)+"_"+str(j))
            tmp.append(e)
        z.append(tmp) 

    rule1 = syp.true

    for i in range(height):
        for j in range(width):
            if(grid[i][j]==" "):
                continue

            tmp =  [ x[i][j]  , x[i+1][j] , z[i][j] , z[i][j+1] ]
            if( grid[i][j] == "0"):
                rule1 = rule1 & none(tmp)
            elif( grid[i][j] == "1"):
                rule1 = rule1 & exactlyOne(tmp)
            elif( grid[i][j] == "2"):
                rule1 = rule1 & exactlyTwo(tmp)
            elif( grid[i][j] == "3"):
                rule1 = rule1 & exactlyOneNot(tmp)

    twoLine = syp.true

    for i in range(1,height):
        for j in range(1,width):
            tmp =  [z[i][j]  , z[i-1][j]  , x[i][j] , x[i][j-1]]
            twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )

    for i in range(1,height):
        tmp =  [ z[i][0]  , z[i-1][0]  , x[i][0] ]
        twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )
    for i in range(1,height):
        tmp =  [ z[i][width]  , z[i-1][width]  , x[i][width-1] ]
        twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )
    for j in range(1,width):
        tmp =  [ z[0][j] , x[0][j] , x[0][j-1] ]
        twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )
    for j in range(1,width):
        tmp =  [ z[height-1][j] , x[height][j] , x[height][j-1] ]
        twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )

    tmp =  [z[0][0], x[0][0] ]
    twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )
    

    tmp =  [ z[0][width], x[0][width-1] ]
    twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )

    tmp =  [z[height-1][0], x[height][0]]
    twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )

    tmp =  [z[height-1][width], x[height][width-1] ]
    twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )

    ansZ=[]
    ansX=[]
    def next_egde(previous_,current_):
        next_ = current_[0],current_[1]+1
        if( current_[1]!=width and next_ != previous_  and ansX[current_[0]][current_[1]]):
            return next_

        next_ = current_[0]+1,current_[1]
        if( current_[0] != height and ansZ[current_[0]][current_[1]] and next_ != previous_ ):
            return next_

        next_ = current_[0]-1,current_[1]
        if( current_[0] != 0  and ansZ[next_[0]][next_[1]] and next_ != previous_ ):
            return next_
        next_ = current_[0],current_[1]-1
        if( current_[1] != 0 and ansX[next_[0]][next_[1]] and next_ != previous_ ):
            return next_
        return (-1,-1)
    
    sat = rule1 & twoLine
    solved =False
    startTime = time()
    while(True):
        sol = syp.satisfiable(sat)
        if(sol == False):
            print("NO Solution")
            solved = False
            break

        ansZ=[]
        ansX=[]
        for i in range(xRow):
            tmp = []
            for j in range(xCol):
                tmp.append(sol[x[i][j]])
            ansX.append(tmp)
        for i in range(zRow):
            tmp =[]
            for j in range(zCol):
                tmp.append(sol[z[i][j]])
            ansZ.append(tmp)
        
        s = sum([1 for i in range(height+1) for j in range(width) if ansX[i][j] ]) + sum([ 1 for i in range(height) for j in range(width+1) if ansZ[i][j] ])
        
        count_edges_cylcle = 0
        #find first activated edge
        start = (-1,-1)
        found = False
        for i in range(height+1):
            for j in range(width):
                if(ansX[i][j]):
                    start = i,j
                    found = True
                    break
            if(found):
                break
        if(start==(-1,-1)):
            print("error")
            solved = False
            break
        current =next_egde(start,start)
        
        count_edges_cylcle+=1
        previous = start[0],start[1]
        while(current != start and current != (-1,-1) ):
            previous,current =current, next_egde(previous,current)
            count_edges_cylcle+=1
        if(s==count_edges_cylcle):
            solved = True
            break
        
        oneloop = syp.true

        for i in range(xRow):
            for j in range(xCol):
                if(ansX[i][j]):
                    oneloop = oneloop & x[i][j]
        for i in range(zRow):
            for j in range(zCol):
                if(ansZ[i][j]):
                    oneloop = oneloop & z[i][j]
        sat = sat & ( ~oneloop )
    endTime = time()
    return solved,[ansX,ansZ],(endTime-startTime)




