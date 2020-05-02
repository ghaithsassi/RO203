using CPLEX
using JuMP
#include("generation.jl")

function cplexSolve(h::Array{Int, 1},v::Array{Int, 1},A::Tuple{Int,Int,Int},B::Tuple{Int,Int,Int},L::Array{Tuple{Int,Int,Int},1})
    """
    "=" #1
    "║" #2
    "╚" #3
    "╔" #4
    "╗" #5
    "╝" #6
    """

    n = size(v,1)
    m = size(h,1)

    md = Model(with_optimizer(CPLEX.Optimizer))
    @variable(md, x[1:n, 1:m,1:6], Bin)

    @variable(md, y[1:n, 1:m], Bin)
    @variable(md, z[1:n, 1:m], Bin)

    @variable(md, r[1:n, 1:m], Bin)

    @variable(md, ru[1:n, 1:m], Bin)
    @variable(md, rl[1:n, 1:m], Bin)
    @variable(md, rd[1:n, 1:m], Bin)
    @variable(md, rr[1:n, 1:m], Bin)

    @constraint(md,[i in 1:n,j in 1:m] ,sum(x[i,j,k] for k in 1:6) <= 1 )
    @constraint(md,[i in 1:n],sum(x[i,j,k] for j in 1:m for k in 1:6) == v[i] )
    @constraint(md,[j in 1:m],sum(x[i,j,k] for i in 1:n for k in 1:6) == h[j] )

    @constraint(md,[e in L],x[e[1],e[2],e[3]]==1)
    
    @constraint(md,x[A[1],A[2],A[3]] == 1 )
    @constraint(md,x[B[1],B[2],B[3]] == 1)

    ##
    @constraint(md,r[A[1],A[2]] == 1)
    

    fixed = Set{Tuple{Int,Int}}()
    for e in L
        push!(fixed,(e[1],e[2]))
    end
    push!(fixed,(A[1],A[2]))
    push!(fixed,(B[1],B[2]))

    for i in 1:n
        if( !in((i,1),fixed ))
            @constraint(md, x[i,1,1]+ x[i,1,3]+ x[i,1,5] == 0)
        end
        if( !in((i,m),fixed ) )
            @constraint(md, x[i,m,1]+ x[i,m,3]+ x[i,m,4] == 0)
        end
    end
    for j in 1:m
        if( !in((1,j),fixed) )
            @constraint(md,x[1,j,2]+x[1,j,3]+x[1,j,6] == 0)
        end
        if( !in((n,j),fixed) )
            @constraint(md,x[n,j,2]+x[n,j,4]+x[n,j,5] == 0)
        end
    end

    @constraint(md,[i in 1:n,j in 2:m] ,x[i,j,1]+ x[i,j,5]+x[i,j,6]+x[i,j-1,1]+x[i,j-1,3]+x[i,j-1,4]-2*y[i,j]==0)
    @constraint(md,[i in 2:n,j in 1:m] ,x[i,j,2]+ x[i,j,3]+x[i,j,6]+x[i-1,j,2]+x[i-1,j,5]+x[i-1,j,4]-2*z[i,j]==0)



    @constraint(md,[i in 1:n,j in 2:m], rl[i,j] - 0.5*y[i,j]- 0.5*r[i,j-1] <= 0)
    @constraint(md,[i in 1:n,j in 2:m], -rl[i,j]+y[i,j]+r[i,j-1] <= 1)

    @constraint(md,[i in 2:n,j in 1:m], ru[i,j] -0.5*z[i,j]-0.5*r[i-1,j]<=0 )
    @constraint(md,[i in 2:n,j in 1:m], -ru[i,j] +z[i,j]+r[i-1,j] <=1 )



    @constraint(md, x[1,2,1]+x[1,2,5]+x[1,2,6]-y[1,1]==0)
    @constraint(md, x[2,1,2]+x[2,1,3]+x[2,1,6]-z[1,1]==0)
    

    @constraint(md,[i in 1:n,j in 1:m-1], rr[i,j] - 0.5*y[i,j+1]- 0.5*r[i,j+1] <= 0)
    @constraint(md,[i in 1:n,j in 1:m-1], -rr[i,j]+y[i,j+1]+r[i,j+1] <= 1)

    @constraint(md,[i in 1:n-1,j in 1:m], rd[i,j] -0.5*z[i+1,j]-0.5*r[i+1,j]<=0 )
    @constraint(md,[i in 1:n-1,j in 1:m], -rd[i,j] +z[i+1,j]+r[i+1,j] <=1 )


    @constraint(md,[j in 1:m],ru[1,j]==0)
    @constraint(md,[i in 1:n],rl[i,1]==0)
    @constraint(md,[j in 1:m],rd[n,j]==0)
    @constraint(md,[i in 1:n],rr[i,m]==0)
    
    @constraint(md,[i in 1:n,j in 1:m],ru[i,j]-r[i,j]<=0)
    @constraint(md,[i in 1:n,j in 1:m],rl[i,j]-r[i,j]<=0)
    @constraint(md,[i in 1:n,j in 1:m],rd[i,j]-r[i,j]<=0)
    @constraint(md,[i in 1:n,j in 1:m],rr[i,j]-r[i,j]<=0)
    @constraint(md,[i in 1:n,j in 1:m],r[i,j]-ru[i,j]-rd[i,j]-rl[i,j]-rr[i,j]<=0)

    @constraint(md,sum(r[i,j] for i in 1:n for j in 1:m)-sum(x[i,j,k] for i in 1:n for j in 1:m for k in 1:6) ==0)

    

    #@objective(md, Min, sum(r[i,j] for i in 1:n for j in 1:m ) )




    start = time()
    optimize!(md)
    println(JuMP.value(rr[2,5]))

    return JuMP.primal_status(md) == JuMP.MathOptInterface.FEASIBLE_POINT,x, time() - start


end


"""
Solve all the instances contained in "../data" through CPLEX and the heuristic

The results are written in "../res/cplex" and "../res/heuristic"

Remark: If an instance has previously been solved (either by cplex or the heuristic) it will not be solved again
"""
function solveDataSet()

    dataFolder = "../data/"
    resFolder = "../res/"

    resolutionMethod = ["cplex", "heuristique"]
    resolutionFolder = resFolder .* resolutionMethod
    
    for folder in resolutionFolder
        if !isdir(folder)
            mkdir(folder)
        end
    end
            
    global isOptimal = false
    global solveTime = -1

    # For each input file
    # (for each file in folder dataFolder which ends by ".txt")
    for file in filter(x->occursin(".txt", x), readdir(dataFolder))  
        
        println("-- Resolution of ", file)
        t = readInputFile(dataFolder * file)

        # For each resolution method
        for methodId in 1:size(resolutionMethod, 1)
            
            outputFile = resolutionFolder[methodId] * "/" * file

            # If the input file has not already been solved by this method
            if !isfile(outputFile)
                
                fout = open(outputFile, "w")  

                resolutionTime = -1
                isOptimal = false
                
                # If the method is cplex
                if resolutionMethod[methodId] == "cplex"

                    # Solve it and get the results
                    isOptimal, x, resolutionTime = cplexSolve(t)
                    
                    # Also write the solution (if any)
                    if isOptimal
                        writeSolution(fout, x)
                    end

                # If the method is one of the heuristics
                else
                    
                    isSolved = false
                    solution = []

                    # Start a chronometer 
                    startingTime = time()
                    
                    # While the grid is not solved and less than 100 seconds are elapsed
                    while !isOptimal && resolutionTime < 100
                        print(".")

                        isOptimal, solution = heuristicSolve(t, resolutionMethod[methodId] == "heuristique2")

                        # Stop the chronometer
                        resolutionTime = time() - startingTime
                    end

                    println("")

                    # Write the solution (if any)
                    if isOptimal
                        writeSolution(fout, solution)
                    end 
                end

                println(fout, "solveTime = ", resolutionTime) 
                println(fout, "isOptimal = ", isOptimal) 
                close(fout)
            end


            # Display the results obtained with the method on the current instance
            include(outputFile)
            println(resolutionMethod[methodId], " optimal: ", isOptimal)
            println(resolutionMethod[methodId], " time: " * string(round(solveTime, sigdigits=2)) * "s\n")
        end         
    end 
end


h = [3,2,3,4,7,6,4,6]
v = [8,4,4,5,4,4,4,2]
A = (3,1,6)
B = (8,2,4)
l=[(2,5,4)]
solved,x,tm = cplexSolve(h,v,A,B,l)
print(tm)
displaySolution(h,v,x)