from numpy.random import randint
from numpy.random import binomial

def generate_loop(height,width,minLoopLength):
    grid = []
    for _ in range(height):
        tmp = []
        for __ in range(width):
            tmp.append(" ")
        grid.append(tmp)
    loop = False
    k = 0
    while(True):
        x = []
        z = []
        for _ in range(height+1):
            tmp = []
            for __ in range(width):
                tmp.append(False)
            x.append(tmp)
        for _ in range(height):
            tmp = []
            for __ in range(width+1):
                tmp.append(False)
            z.append(tmp)
        start = randint(0,height+1), randint(0,width+1)
        current = start
        visited  = set()
        visited.add(start)
        k = 0
        while(True):
            k+=1
            pseudo_possible = [ (current[0]+1,current[1]) ,(current[0]-1,current[1]) ,(current[0],current[1]+1) , (current[0],current[1]-1)]

            possible = []
            for e in pseudo_possible:
                if (e[0] >= 0) and (e[0] <= height) and (e[1] >= 0 ) and (e[1] <= width ) and (not(e in visited) or (e == start and k>4) ):
                    possible.append(e)
            if(len(possible)==0):
                break
            v = randint(0,len(possible))
            next_  = possible[v]
            if(current[0]+1==next_[0]):
                z[current[0]][current[1]] = True
            elif(current[0]-1==next_[0]):
                z[next_[0]][next_[1]] = True
            elif(current[1]+1 == next_[1]):
                x[current[0]][current[1]] = True
            elif(current[1]-1==next_[1]):
                x[next_[0]][next_[1]] = True

            visited.add(next_)
            current = next_


            if(current == start):
                loop = True
                break
        if(loop and k >= minLoopLength):
            break
        loop = False
    return grid,x,z

def fill_grid(grid,x,z,p):
    height = len(grid)
    width = len(grid[0])

    for i in range(height):
        for j in range(width):
            tmp =  [ x[i][j]  , x[i+1][j] , z[i][j] , z[i][j+1] ]
            s = sum([1 for e in tmp if e])
            if(s==0):
                rd = binomial(1,p[0])
            elif(s==1):
                rd = binomial(1,p[1])
            elif(s==2):
                rd = binomial(1,p[2])
            elif(s==3):
                rd = binomial(1,p[3]) 
            if(rd == 1):
                grid[i][j] = str(s)
    return grid
def generateInstanc():
    p = [0.15,0.4,0.5,0.5]
    f = 0.7
    height = randint(5,10)
    width = randint(5,10)
    minLoopLength = int(height*width*f)
    grid,x,z = generate_loop(height,width,minLoopLength)
    grid = fill_grid(grid,x,z,p)
    return grid
    



        
    
