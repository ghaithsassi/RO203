using JuMP
using CPLEX
using Distributions 


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



function displaySolution(t::Array{Char,2},x::Array{VariableRef,2},z::Array{VariableRef,2})
    height = size(t,1)
    width = size(t,2)
    
    xHeight = height +1
    xWidth =  width

    zHeight = height
    zWidth = width + 1

    println("")
    for i in 1:height
        for j in 1:xWidth
            if( JuMP.value(x[i,j])>0 )
                print(".__")
            else
                print(".  ")
            end
        end
        println(".")
        for j in 1:zWidth
            if( JuMP.value(z[i,j])>0)
                print("| ")
            else
                print("  ")
            end
            if(j<=width)
                print(t[i,j])
            end
        end
        println("")
    
        
    end
    for j in 1:xWidth
        if( JuMP.value(x[xHeight,j])>0 )
            print(".__")
        else
            print(".  ")
        end
    end
    println(".")
end


function generateLoop(height::Int,width::Int,minLoopLength::Int)
    grid = Array{Char}(undef,height,width)
    fill!(grid,' ')
    
    loop = false
    k = 0

    x = Array{Bool}(undef,height+1,width)
    z = Array{Bool}(undef,height,width+1)

    start = ( ceil(Int,rand()*(height+1) ), ceil(Int,rand()*(width+1) ) )

    deadend= Set{ Tuple{Int,Int,Int} }()
    push!(deadend,(start[1],start[2],0))
    
    while(true)
        fill!(x,false)
        fill!(z,false)
        
        current = start
        visited  = Set{Tuple{Int,Int}}()
        push!(visited,start)
        k = 0
        while(true)
            k+=1

            pseudo_possible = Array{Tuple{Int,Int}}([ (current[1]+1,current[2]) ,(current[1]-1,current[2]) ,(current[1],current[2]+1) , (current[1],current[2]-1)])
            possible = Array{Tuple{Int,Int}}(undef,0)
            for el in 1:size(pseudo_possible,1)
                e=pseudo_possible[el]
                if (e[1] > 0) && (e[1] <= height+1) && (e[2] >= 1 ) && (e[2] <= width+1 ) && ( !in(e,visited) ||  (e == start && k>4) && !in((e[1],e[2],k),deadend))
                    push!(possible,e)
                end
            end
            q = size(possible,1)
            if( q==0 )
                push!(deadend,(current[1],current[2],k))
                break
            end
            v = ceil(Int,rand()*q)
            next_  = possible[v]
            if(current[1]+1==next_[1])
                z[current[1],current[2]] = true
            elseif(current[1]-1==next_[1])
                z[next_[1],next_[2]] = true
            elseif(current[2]+1 == next_[2])
                x[current[1],current[2]] = true
            elseif(current[2]-1==next_[2])
                x[next_[1],next_[2]] = true
            end

            push!(visited,next_ )
            current = next_

            if(current == start)
                loop = true
                break
            end
        end
        if(loop && k >= minLoopLength)
            break
        end
        loop = false
    end
    for i in 1:(height)
        for j in 1:(width)
            tmp =  [ x[i,j] , x[i+1,j], z[i,j] , z[i,j+1] ]
            s = sum([1 for e in tmp if e])
            if(s==0)
                rd = Distributions.Binomial(1,p[1])
            elseif(s==1)
                rd = Distributions.Binomial(1,p[2])
            elseif(s==2)
                rd = Distributions.Binomial(1,p[3])
            elseif(s==3)
                rd = Distributions.Binomial(1,p[4]) 
            end
            if(rand(rd) == 1)
                grid[i,j] = Char(s+48)
            end
        end
    end
    return grid
end
function generateInstance(height::Int64,width::Int64, density::Float64,p::Array{Float64,1})
    minLoopLength = ceil(Int,height*width*density)
    grid = generateLoop(height,width,minLoopLength)
    
    return grid
end

"""
t =[ 
'0' ' ' '1' ' ' ' ';
' ' ' ' '1' ' ' ' ';
' ' ' ' ' ' ' ' '1';
' ' '2' '2' '3' ' ';
'3' '2' '2' '2' '2';
' ' '1' ' ' '2' '1';
' ' ' ' '3' '1' '0']
"""

t =[
' ' ' ' '2' ' ' ' ' ' ' ' ' ' ' ' ';
'2' ' ' ' ' '1' '0' ' ' ' ' ' ' ' ';
' ' '2' '2' ' ' ' ' ' ' ' ' '0' ' ';
' ' ' ' ' ' ' ' ' ' ' ' '0' ' ' ' ';
' ' ' ' ' ' ' ' ' ' '1' ' ' '0' ' ';
'2' '0' ' ' '3' ' ' ' ' ' ' ' ' ' ';
' ' ' ' '3' ' ' '2' '1' '1' '2' ' ';
' ' ' ' '2' ' ' '2' '1' ' ' ' ' ' ';
'2' ' ' '3' ' ' '2' '1' ' ' ' ' ' ']

t= [
' ' ' ' ' ' ' ' ' ' ' ' '1';
' ' ' ' ' ' '0' '2' ' ' ' ';
' ' '0' ' ' ' ' ' ' ' ' '1';
' ' ' ' '3' ' ' '3' ' ' ' ';
' ' '2' ' ' ' ' '2' ' ' '3';
'2' '2' '2' ' ' '3' '1' ' ';
'2' '2' '2' ' ' '2' ' ' ' ';
' ' ' ' ' ' '2' ' ' ' ' '2';]

a,x,z,tm = cplexSolve(t)
displaySolution(t,x,z)
s = oneLoopRule(x,z)
println(s," ",tm)


p = [0.1,0.6,0.5,0.5]
t = generateInstance(10,10,0.7,p)
println("done")
a,x,z,tm = cplexSolve(t)
displaySolution(t,x,z)