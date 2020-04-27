from sympy import *
from sympy.logic.boolalg import to_cnf
def none(L):
    ans = true
    for e in L:
        ans = ans & ~e
    return ans
def atLeastOne(L):
    ans= false
    for e in L:
        ans = ans | e
    return ans
def atMostOne(L):
    ans = true
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
    ans = false
    for i in range(len(L)-1):
        for j in range(i+1,len(L)):
            for k in range(len(L)):
                if( k != i and k != j):
                    ans = ans | ( L[i]&L[j]& ~L[k])
    return ans   


def solve_(grid):
    height = len(grid)
    width = len(grid[0])

    xRow = height+1
    xCol = width

    zRow = height
    zCol = width+1

    xLength = xRow * xCol

    def convertXIndex(i,j):
        return i*xCol+j+1
    def convertZIndex(i,j):
        return i*xCol+j+1+xLength

    var = []
    for i in range(xRow):
        for j in range(xCol):
            e = symbols("x"+str(convertXIndex(i,j)))
            var.append(e)
    for i in range(zRow):
        for j in range(zCol):
            e = symbols("x"+str(convertZIndex(i,j)))
            var.append(e) 
    print(len(var))
    rule1 = true

    for i in range(height):
        for j in range(width):
            if(grid[i][j]==" "):
                continue

            tmp =  [var[convertXIndex(i,j)-1]  , var[convertXIndex(i+1,j)-1]  , var[convertZIndex(i,j)-1] , var[convertXIndex(i,j+1)-1]]
            if( grid[i][j] == "0"):
                rule1 = rule1 & none(tmp)
            elif( grid[i][j] == "1"):
                rule1 = rule1 & exactlyOne(tmp)
            elif( grid[i][j] == "2"):
                rule1 = rule1 & exactlyTwo(tmp)
            elif( grid[i][j] == "3"):
                rule1 = rule1 & exactlyOneNot(tmp)

    twoLine = true

    for i in range(1,height):
        for j in range(1,width):
            tmp =  [var[convertZIndex(i,j)-1]  , var[convertZIndex(i-1,j)-1]  , var[convertXIndex(i,j)-1] , var[convertXIndex(i,j-1)-1]]
            twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )

    for i in range(1,height):
        tmp =  [var[convertZIndex(i,0)-1]  , var[convertZIndex(i-1,0)-1]  , var[convertXIndex(i,0)-1] ]
        twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )
    for i in range(1,height):
        tmp =  [var[convertZIndex(i,width)-1]  , var[convertZIndex(i-1,width)-1]  , var[convertXIndex(i,width-1)-1] ]
        twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )
    for j in range(1,width):
        tmp =  [var[convertZIndex(0,j)-1] , var[convertXIndex(0,j)-1] , var[convertXIndex(0,j-1)-1]]
        twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )
    for j in range(1,width):
        tmp =  [var[convertZIndex(height-1,j)-1], var[convertXIndex(height,j)-1] , var[convertXIndex(height,j-1)-1]]
        twoLine = twoLine & ( none(tmp) | exactlyTwo(tmp) )

    tmp =  [var[convertZIndex(0,0)-1], var[convertXIndex(0,0)-1] ]
    twoLine = twoLine & ( none(tmp) | (tmp[0]&tmp[1]) )
    

    tmp =  [var[convertZIndex(0,width)-1], var[convertXIndex(0,width-1)-1] ]
    twoLine = twoLine & ( none(tmp) | (tmp[0]&tmp[1]) )

    tmp =  [var[convertZIndex(height-1,0)-1], var[convertXIndex(height,0)-1] ]
    twoLine = twoLine & ( none(tmp) | (tmp[0]&tmp[1]) )

    tmp =  [var[convertZIndex(height-1,width)-1], var[convertXIndex(height,width-1)-1] ]
    twoLine = twoLine & ( none(tmp) | (tmp[0]&tmp[1]) )

    return twoLine

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

q=solve_(L)
print(q)
print(satisfiable(q))

