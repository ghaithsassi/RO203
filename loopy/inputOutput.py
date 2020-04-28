def readInputFile(s):
    file = open(s,"r")
    L = file.readlines()
    grid =[]
    for e in L:
        tmp = e.split(",")
        if tmp[-1] == "\n" or tmp[-1] == "":
            grid.append(tmp[:-1])
        else:
            grid.append(tmp)
    return grid

def displaySolution(grid,x,z):
    height = len(grid)
    width = len(grid[0])

    for i in range(height):
        ch1=" "
        ch2=""  
        for j in range(width):
            if( not(x[i][j]) ):
                ch1+= ".  "
            else:
                ch1+= "___"
            ch1 += " "

            if( not(z[i][j]) ):
                ch2 +=" "
            else:
                ch2 +="|"
            ch2 += " "+ grid[i][j] + " "
        ch1+="."
        
        if( not(z[i][width] )):
            ch2 +=" "
        else:
            ch2 +="|"
        
        print(ch1)
        print(ch2)
    ch1 = " "
    for j in range(width):
            if(not(x[height][j])):
                ch1+= ".  "
            else:
                ch1+= "___"
            ch1 += " "
    ch1+="."
    print(ch1)

def displayGrid(grid):
    height = len(grid)
    width = len(grid[0])

    for i in range(height):
        ch1=" "
        ch2=""  
        for j in range(width):
            ch1+= ".   "
            ch2 += "  "+ grid[i][j] + " "
        ch1+="."       
        print(ch1)
        print(ch2)
    ch1 = " "
    for j in range(width):
            ch1+= ".   "
    ch1+="."
    print(ch1)

