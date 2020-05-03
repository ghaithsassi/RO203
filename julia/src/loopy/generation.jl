using Distributions 
include("io.jl")


function generateLoop(height::Int,width::Int,minLoopLength::Int,p::Array{Float64,1})
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
                if (e[1] > 0) && (e[1] <= height+1) && (e[2] >= 1 ) && (e[2] <= width+1 ) && ( !in(e,visited) ||  (e == start && k>4) ) && !in((e[1],e[2],k),deadend)
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
    grid = generateLoop(height,width,minLoopLength,p)
    
    return grid
end


function generateDataSet()

    p = [0.1,0.6,0.5,0.5]
    

    # For each grid size considered
    for size in [4,5,7,8]

        # For each grid density considered
        for density in 0.1:0.2:0.3

            # Generate 10 instances
            for instance in 1:10

                fileName = "../data/instance_t" * string(size) * "_d" * string(density) * "_" * string(instance) * ".txt"

                if !isfile(fileName)
                    println("-- Generating file " * fileName)
                    saveInstance(generateInstance(size,size, density,p), fileName)
                end 
            end
        end
    end
end