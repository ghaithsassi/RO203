using Distributions 
include("io.jl")
function generateTrack(n::Int,m::Int,minTrackLength::Int)
    grid = Array{Char}(undef,n,m)
    fill!(grid,'*')
    height = n-1
    width = m-1

    done = false
    k = 0

    x = Array{Bool}(undef,height+1,width)
    z = Array{Bool}(undef,height,width+1)

    start = ( ceil(Int,rand()*(height+1) ),1 )
    exit = Tuple{Int,Int}

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
                if (e[1] > 0) && (e[1] <= height+1) && (e[2] >= 1 ) && (e[2] <= width+1 ) && !in(e,visited) && !in((e[1],e[2],k),deadend) 
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
            rd = Distributions.Binomial(1,0.5)
            if(current[1]== n && rand(rd)==1 )
                exit = current
                done = true
                break
            end
        end
        if(done && k >= minTrackLength)
            break
        end
        done = false
    end

    for i in 2:height
        for j in 2:width
            if( x[i,j-1] && x[i,j])
                grid[i,j] = '='
            elseif( x[i,j-1] && z[i-1,j])
                grid[i,j] = '╝'
            elseif( x[i,j-1] && z[i,j])
                grid[i,j] = '╗'
            elseif( z[i-1,j] && z[i,j])
                grid[i,j] = '║'
            elseif(z[i-1,j] && x[i,j])
                grid[i,j]= '╚'
            elseif(z[i,j] && x[i,j])
                grid[i,j] = '╔'
            end
           
        end
    end
    for i in 2:height
        if( x[i,m-1] && z[i,m])
            grid[i,m] = '╗'
        elseif( x[i,m-1] && z[i-1,m])
            grid[i,m] = '╝'
        elseif( z[i-1,m] && z[i,m])
            grid[i,m] = '║'
        end
    end
    for i in 2:height   
        if(z[i-1,1] && x[i,1])
            grid[i,1]= '╚'
        elseif(z[i,1] && x[i,1])
            grid[i,1] = '╔'
        elseif( z[i-1,1] && z[i,1])
            grid[i,1] = '║'
        end
    end

    for j in 2:width
        if( x[1,j-1] && x[1,j])
            grid[1,j] = '='
        elseif(z[1,j] && x[1,j])
            grid[1,j] = '╔'
        elseif( x[1,j-1] && z[1,j])
            grid[1,j] = '╗'
        end
    end 
    for j in 2:width
        if( x[n,j-1] && x[n,j])
            grid[n,j] = '='
        elseif(z[n-1,j] && x[n,j])
            grid[n,j]= '╚'
        elseif( x[n,j-1] && z[n-1,j])
            grid[n,j] = '╝'
        end
    end

    if(x[1,1] && z[1,1])
        grid[1,1] = '╔'
    end
    if(x[n,1] && z[n-1,1])
        grid[n,1]= '╚'
    end
    if(x[1,m-1]&& z[1,m])
        grid[1,m] = '╗'
    end
    if(x[n,m-1] && z[n-1,m])
        grid[n,m] = '╝'
    end

    if(grid[start[1],start[2]+1] == '=' ||  grid[start[1],start[2]+1]=='╝' || grid[start[1],start[2]+1]== '╗')
        grid[start[1],start[2]] = '='
    end
    if(start[1]>1)
        if(grid[start[1]-1,start[2]] == '║' ||  grid[start[1]-1,start[2]]=='╔')
            grid[start[1],start[2]] = '╝'
        end
    end
    if(start[1]<n)

        if(grid[start[1]+1,start[2]] == '║' ||  grid[start[1]+1,start[2]]=='╚')
            grid[start[1],start[2]] = '╗'
        end
    end



    if(grid[exit[1]-1,exit[2]] == '║' ||  grid[exit[1]-1,exit[2]]=='╔' || grid[exit[1]-1,exit[2]]== '╗')
        grid[exit[1],exit[2]] = '║'
    end
    if(exit[2]<m)
        if(grid[exit[1],exit[2]+1] == '=' ||  grid[exit[1],exit[2]+1]=='╝')
            grid[exit[1],exit[2]] = '╔'
        end
    end
    if(exit[2]>1)
        if(grid[exit[1],exit[2]-1] == '=' ||  grid[exit[1],exit[2]-1]=='╚')
            grid[exit[1],exit[2]] = '╗'
        end
    end
    
    

    return grid,start,exit
end


function cellTypeId(s::Char)
    if(s == '=')
        return 1
    elseif( s == '║')
        return 2
    elseif(s =='╚' )
        return 3
    elseif(s == '╔')
        return 4
    elseif( s == '╗')
        return 5
    elseif(s == '╝')
        return 6
    end
    return 0
end

function generateInstance(n::Int , m::Int , density::Float64)
    minTrackLength = ceil(Int,(n * m * density))
    grid ,start,exit =  generateTrack(n,m,minTrackLength)
    h = Array{Int}(undef,m)
    v= Array{Int}(undef,n)

    for i in  1:n
        v[i]= 0
        for j in 1:m
            if(grid[i,j]!='*')
                v[i] = v[i] + 1
            end
        end
    end
    for j in 1:m
        h[j] = 0
        for i in 1:n
            if(grid[i,j]!='*')
                h[j] = h[j]+1
            end
        end
    end

    A = (start[1],start[2],cellTypeId(grid[start[1],start[2]]))
    B = (exit[1],exit[2],cellTypeId(grid[exit[1],exit[2]]))
    L = Array{Tuple{Int,Int,Int}}(undef,0)

    for i in 1:n
        for j in 1:m
            rd = Distributions.Binomial(1,0.10)
            if(cellTypeId(grid[i,j])!= 0 && rand(rd) == 1 && (i,j)!=(A[1],A[2]) && (i,j) != (B[1],B[2]) )
                push!(L,(i,j,cellTypeId(grid[i,j])))
            end
        end
    end
    println("")
    for i in 1:n
        for j in 1:m
            print(grid[i,j]," ")
        end
        println("")
    end
    return h,v,A,B,L
end

function generateDataSet()

    # For each grid size consclidered
    for size in [4,7,8, 9, 10]

        # For each grid density considered
        for density in 0.1:0.2:0.3

            # Generate 10 instances
            for instance in 1:10

                fileName = "../data/instance_t" * string(size) * "_d" * string(density) * "_" * string(instance) * ".txt"

                if !isfile(fileName)
                    println("-- Generating file " * fileName)
                    h,v,A,B,L = generateInstance(size,size, density)

                    saveInstance(h,v,A,B,L, fileName)
                end 
            end
        end
    end
end

