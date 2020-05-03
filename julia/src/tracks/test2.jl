
function next_stop(t::Array{Int,3}, curr::Tuple{Int,Int,Int},h::Array{Int, 1},v::Array{Int, 1}, ha::Array{Int, 1},va::Array{Int, 1})
    next_step = Array{Tuple{Int,Int,Int}}(undef,0)
    found = false

    if ((curr[3]==1) || (curr[3]==3)||(curr[3]==4))
        
        if (ha[curr[1]]+1 < h[curr[1]]) && (va[curr[2]]<v[curr[2]]) && (sum(t[curr[1],curr[2]+1,k] for k in 1:6) == 0)
            if  (ha[curr[1]]+1 < h[curr[1]]-1)
                push!(next_step,(curr[1],curr[2]+1,1)) 
                ha[curr[1]]+=1
                va[curr[2]+1]+=1
                found = true
            end     
            if (ha[curr[1]+1] < h[curr[1]+1])&&(va[curr[2]+1] < v[curr[2]+1])
                    push!(next_step,(curr[1],curr[2]+1,5)) 
                    ha[curr[1]]+=1
                    va[curr[2]+1]+=1
                    found = true
            end    
                
            if  (ha[curr[1]-1] < h[curr[1]+-1])&&(va[curr[2]+1] < v[curr[2]+1]) 
                    push!(next_step,(curr[1],curr[2]+1,6)) 
                    ha[curr[1]]+=1
                    va[curr[2]+1]+=1 
                    found = true
                
            end
        end
    elseif  (curr[3]==2)||(curr[3]==5)  
            if    (ha[curr[1]+1] < h[curr[1]+1]) && (va[curr[2]]+1<v[curr[2]]) && (sum(t[curr[1]+1,curr[2],k] for k in 1:6) == 0) 
                if  (va[curr[2]+1] < v[curr[2]+1])&&(ha[curr[1]+1]+1 < h[curr[1]])
                    push!(next_step,(curr[1]+1,curr[2],3)) 
                    ha[curr[1]+1]+=1
                    va[curr[2]]+=1
                    found = true
                end    
                if (ha[curr[1]+1]+1 < h[curr[1]])&&(va[curr[2]-1] < v[curr[2]-1])
                    push!(next_step,(curr[1]+1,curr[2],6)) 
                    ha[curr[1]+1]+=1
                    va[curr[2]]+=1
                    found = true
                end                            
                    
                if (curr[1]+1<size(t,1))&&(ha[curr[1]+2] < h[curr[1]+2])&&(va[curr[2]] < v[curr[2]])
                    
                    push!(next_step,(curr[1]+1,curr[2],2)) 
                    ha[curr[1]+1]+=1
                    va[curr[2]]+=1 
                    found = true
                        
                end 
            end
    elseif  (curr[3]==2)||(curr[3]==6)   
        if    (ha[curr[1]-1] < h[curr[1]-1]) && (va[curr[2]]+1<v[curr[2]]) && (sum(t[curr[1]-1,curr[2],k] for k in 1:6) == 0) 
            if  (va[curr[1]+1]+1 < v[curr[1]+1])&&(ha[curr[1]-1]+1 < h[curr[1]+1])
                push!(next_step,(curr[1]-1,curr[2],4)) 
                ha[curr[1]-1]+=1
                va[curr[2]]+=1
                found = true
            end
            if (ha[curr[1]-1]+1 < h[curr[1]-1])&&(va[curr[2]-1] < v[curr[2]-1])
                push!(next_step,(curr[1],curr[2]+1,5)) 
                ha[curr[1]-1]+=1
                va[curr[2]]+=1
                found = true

            end    
            if (curr[1]-1<size(t,1))&&(ha[curr[1]-2] < h[curr[1]-2])&&(va[curr[2]] < v[curr[2]])
                
                push!(next_step,(curr[1]+1,curr[2],2)) 
                ha[curr[1]-1]+=1
                va[curr[2]]+=1 
                found = true
                
            end 
        end              
                    
        
       
    end 
    
    return next_step,found

end

function heuristicSolve(t::Array{Int, 3}, A::Tuple{Int,Int,Int},B::Tuple{Int,Int,Int})

    n = size(t, 1)
    m = size(t,2)
    grid = copy(t)
    current = (A[1],A[2],A[3])
    previous=(-1,-1,-1)
    destination = (B[1], B[2],B[3])
    arrived = false
    va= [0,0,0,0,0,0,0,0]
    ha = [0,0,0,0,0,0,0,0]
    false_way=(-1,-1,-1)
    i=0
    
    while arrived!= true

        next_step,found= next_stop(grid,current, h,v,ha,va)
        false_way=(-1,-1,-1)
        
        while ( size(next_step,1)>0)
            
            previous=current
            current = next_step[1]
            print(current)
            next2,f = next_stop(grid,current,h,v,ha,va)

            
            if (current==destination)
                arrived= true
                return grid
            end
            if (previous!=(-1,-1,-1))&&(!f)
                false_way=current
                current= previous
                pop!(next_step)
            end
            
            
        end
        if false_way ==(-1,-1,-1)
            grid[current[1],current[2],current[3]]=1
            i+=1
    
        end

        if (i>1000)
            break
        end    


    end
    
    return grid
    
end
A = (3,1,6)

B = (8,2,4)
h = [3,2,3,4,7,6,4,6]
ha= [0,0,0,0,0,0,0,0]
v = [8,4,4,5,4,4,4,2]
va= [0,0,0,0,0,0,0,0]
l= [(2,5,4)]
n = size(v,1)
m = size(h,1)
grid = Array{Int}(undef,n,m,6)
fill!(grid,0)
sol, f = next_stop(grid,A,h,v,ha,va)
print(sol)