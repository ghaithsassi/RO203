using CPLEX
include("generation.jl")

function oneLoopRule(x::Array{VariableRef,2},z::Array{VariableRef,2})
    height = size(z,1)
    width = size(x,2)

    s = sum(JuMP.value(x[i,j]) for i in 1:height+1 for j in 1:width) + sum(JuMP.value(z[i,j]) for i in 1:height for j in 1:width+1)


    function nextNode(previous_::Array{Int64,1},current_::Array{Int64,1})
        
        next_ = [current_[1], current_[2]+1]
        if( current_[2]!= width+1 && next_ != previous_  && JuMP.value(x[current_[1],current_[2]])>0)
            return next_
        end

        next_ = [current_[1]+1,current_[2] ]

        if( current_[1] != height+1 && JuMP.value(z[current_[1],current_[2]])>0 && next_ != previous_ )
            return next_
        end
        next_ = [current_[1]-1,current_[2]]
        if( current_[1] != 1  && JuMP.value(z[next_[1],next_[2]])>0 && next_ != previous_ )
            return next_
        end
        next_ = [current_[1],current_[2]-1]
        if( current_[2] != 1 && JuMP.value(x[next_[1],next_[2]])>0 && next_ != previous_ )
            return next_
        end
        return  [-1, -1]
    end


    count_edges_cylcle = 0
    #find first activated edge
    start = [-1 ,-1]
    found = false
    for i in 1:height+1
        for j in 1:width
            if(JuMP.value(x[i,j])>0)
                start = [i ,j]
                found = true
                break
            end
        end
        if(found)
            break
        end
    end

    if(start==[-1 ,-1])
        println("error")
        return false
    end

    current =nextNode(start,start)
    count_edges_cylcle+=1
    previous = start
    while(current != start && current != [-1,-1] )
        previous,current =current, nextNode(previous,current)
        count_edges_cylcle+=1
    end
    if(s==count_edges_cylcle)
        return true
    else
        return false
    end
end

function cplexSolve(t::Array{Char, 2})

    height = size(t,1)
    width = size(t,2)

    xHeight = height +1
    xWidth =  width

    zHeight = height
    zWidth = width + 1
    
    yHeight = height+1
    yWidth = width+1

    m = Model(with_optimizer(CPLEX.Optimizer))

    
    @variable(m, x[1:xHeight, 1:xWidth], Bin)
    @variable(m, z[1:zHeight, 1:zWidth], Bin)
    @variable(m, y[1:yHeight, 1:yWidth], Bin)
    

    for i in 1:height
        for j in 1:width
            if( t[i,j]!= ' ')
                @constraint(m, x[i,j]+x[i+1,j]+z[i,j]+z[i,j+1] == (Int(t[i,j])-48) ) 
            end
        end
    end


    for i in 2:height
        for j in 2:width
            @constraint(m, z[i,j] + z[i-1,j] +x[i,j] + x[i,j-1]-2*y[i,j] == 0 )
        end
    end

    for i in 2:height
        @constraint(m, z[i,1] + z[i-1,1] +x[i,1] -2*y[i,1] == 0)
    end
    for i in 2:height
        @constraint(m, z[i,zWidth] + z[i-1,zWidth] + x[i,xWidth] -2*y[i,yWidth] == 0 )
    end

    for j in 2:width
        @constraint(m, z[1,j] + x[1,j] + x[1,j-1] -2*y[1,j]== 0 )
    end
    for j in 2:width
        @constraint(m, z[zHeight,j] + x[xHeight,j] + x[xHeight,j-1] -2*y[yHeight,j] == 0)
    end

    @constraint(m, z[1,1] + x[1,1] -2*y[1,1] == 0 )
    @constraint(m, z[1,zWidth] + x[1,xWidth] -2*y[1,yWidth] == 0 )
    @constraint(m, z[zHeight,1] + x[xHeight,1] -2*y[yHeight,1] == 0 )
    @constraint(m, z[zHeight,zWidth] + x[xHeight,xWidth] -2*y[yHeight,yWidth] == 0 )

    
    @objective(m, Max, sum(x[i,j] for i in 1:xHeight for j in 1:xWidth)+sum(z[i,j] for i in 1:zHeight for j in 1:zWidth))
    start = time()

    while(true)
        optimize!(m)
        if(JuMP.primal_status(m) != JuMP.MathOptInterface.FEASIBLE_POINT || oneLoopRule(x,z))
            break
        end
        
        s = sum(JuMP.value(x[i,j]) for i in 1:height+1 for j in 1:width) + sum(JuMP.value(z[i,j]) for i in 1:height for j in 1:width+1)
        
        @constraint(m,sum(x[i,j] for i in 1:xHeight for j in 1:xWidth if(JuMP.value(x[i,j])>0))+sum(z[i,j] for i in 1:zHeight for j in 1:zWidth if(JuMP.value(z[i,j])>0)) <= s-1)
        break
    end
    
    

    """

    function my_callback_function(cb_data)
        
        if !oneLoopRule(callback_value(cb_data,x),z) && JuMP.primal_status(m) == JuMP.MathOptInterface.FEASIBLE_POINT
            s = sum(JuMP.value(x[i,j]) for i in 1:height+1 for j in 1:width) + sum(JuMP.value(z[i,j]) for i in 1:height for j in 1:width+1)
            con = @build_constraint(m,sum(y[i,j] for i in 1:yHeight for j in 1:yWidth)<=10)
            JuMP.MathOptInterface.submit(m, JuMP.MathOptInterface.LazyConstraint(cb_data), con)
        end
        
    end
    JuMP.MathOptInterface.set(m, JuMP.MathOptInterface.LazyConstraintCallback(), my_callback_function)
    optimize!(m)
    """
    
    return JuMP.primal_status(m) == JuMP.MathOptInterface.FEASIBLE_POINT, x,z, time() - start
end



function solveDataSet()

    dataFolder = "../data/"
    resFolder = "../res/"

    resolutionMethod = ["cplex"]
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
                    isOptimal, x,z, resolutionTime = cplexSolve(t)
                    
                    # Also write the solution (if any)
                    if isOptimal
                        writeSolution(fout, x,z)
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

                        isOptimal, solutionX,solutionZ = heuristicSolve(t, resolutionMethod[methodId] == "heuristique2")

                        # Stop the chronometer
                        resolutionTime = time() - startingTime
                    end

                    println("")

                    # Write the solution (if any)
                    if isOptimal
                        writeSolution(fout, solutionX,solutionZ)
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
