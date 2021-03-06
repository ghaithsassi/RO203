# This file contains functions related to reading, writing and displaying a grid and experimental results

using JuMP
using Plots
import GR
TOL = 0.000001

"""
Read a grid from an input file

- Argument:
inputFile: path of the input file

- Example of input file for a 9x9 grid
h = [3,2,3,4,7,6,4,6]
v = [8,4,4,5,4,4,4,2]
A = (3,1,6)
B = (8,2,4)
l= [(2,5,4)]

- Prerequisites
Let n be the grid size.
Each line of the input file must contain n values separated by commas.
A value can be an integer or a white space
"""
function readInputFile(inputFile::String)

    # Open the input file
    datafile = open(inputFile)

    data = readlines(datafile)
    close(datafile)
    
    n = length(split(data[1], ","))
    m = length(split(data[2], ","))

    v = Array{Int64}(undef, n)
    h = Array{Int64}(undef, m)

    lineSplit = split(data[1], ",")
    if size(lineSplit, 1) == n
        for colNb in 1:n
            v[colNb] = parse(Int64, lineSplit[colNb])
        end
    end
    lineSplit = split(data[2], ",")
    if size(lineSplit, 1) == m
        for colNb in 1:m
            h[colNb] = parse(Int64, lineSplit[colNb])
        end
    end

    lineSplit = split(data[3], ",")
    A = ( parse(Int64, lineSplit[1]),parse(Int64, lineSplit[2]),parse(Int64, lineSplit[3]) )

    lineSplit = split(data[4], ",")
    B = ( parse(Int64, lineSplit[1]),parse(Int64, lineSplit[2]),parse(Int64, lineSplit[3]) )

    L = Array{Tuple{Int,Int,Int}}(undef,0)

    for i in 5:size(data,1)
        lineSplit = split(data[i], ",")
        e = ( parse(Int64, lineSplit[1]),parse(Int64, lineSplit[2]),parse(Int64, lineSplit[3]) )
        push!(L,e)
    end

    return h,v,A,B,L

end


function cellType(q::Int64)
    if(q == 1)
        s = '='
    elseif(q == 2)
        s = '║'
    elseif(q == 3)
        s ='╚'
    elseif(q == 4)
        s = '╔'
    elseif(q == 5)
        s = '╗'
    elseif(q == 6)
        s = '╝'
    else
        s = '*'
    end
    return s
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

function displayGrid(h::Array{Int, 1},v::Array{Int, 1},A::Tuple{Int,Int,Int},B::Tuple{Int,Int,Int},L::Array{Tuple{Int,Int,Int},1})
    n = size(v,1)
    m = size(h,1)
    grid = Array{Char}(undef,n,m)
    fill!(grid,'*')
    println(size(grid,2))

    grid[A[1],A[2]] = cellType(A[3])
    grid[B[1],B[2]] = cellType(B[3])

    for e in L 
        grid[e[1],e[2]]=cellType(e[3])
    end    

    println("")
    for j in 1:m
        print(h[j]," ")
    end
    println("")
    for i in 1:n
        println("")
        for j in 1:m 
           print(grid[i,j]," ")
        end
        print(" ",v[i])
    end
end


function displaySolution(h::Array{Int, 1},v::Array{Int, 1},x::Array{VariableRef,3})
    n = size(x,1)
    m = size(x,2)
    println("")
    for j in 1:m
        print(h[j]," ")
    end
    println("")
    for i in 1:n
        println("")
        for j in 1:m 
            if(JuMP.value(x[i,j,1])>0)
                print("= ")
            elseif(JuMP.value(x[i,j,2])>0)
                print("║ ")
            elseif(JuMP.value(x[i,j,3])>0)
                print("╚ ")
            elseif(JuMP.value(x[i,j,4])>0)
                print("╔ ")
            elseif(JuMP.value(x[i,j,5])>0)
                print("╗ ")
            elseif(JuMP.value(x[i,j,6])>0)
                print("╝ ")
            else
                print("* ")
            end
        end
        print(" ",v[i])
    end
end


function saveInstance(h::Array{Int, 1},v::Array{Int, 1},A::Tuple{Int,Int,Int},B::Tuple{Int,Int,Int},L::Array{Tuple{Int,Int,Int},1}, outputFile::String)

    n = size(v,1)
    m = size(h,1)

    # Open the output file
    writer = open(outputFile, "w")

    for i in 1:n
        print(writer,v[i])
        if i != n
            print(writer, ",")
        else
            println(writer, "")
        end
    end

    for j in 1:m
        print(writer,h[j])
        if j != m
            print(writer, ",")
        else
            println(writer, "")
        end
    end

    println(writer,A[1],",",A[2],",",A[3])
    println(writer,B[1],",",B[2],",",B[3])

    for e in L
        println(writer,e[1],",",e[2],",",e[3])
    end
    close(writer)
    
end 


"""
Write a solution in an output stream

Arguments
- fout: the output stream (usually an output file)
- x: 3-dimensional variables array such that x[i, j, k] = 1 if cell (i, j) has value k
"""
function writeSolution(fout::IOStream, x::Array{VariableRef,3})

    # Convert the solution from x[i, j, k] variables into t[i, j] variables
    n = size(x, 1)
    m = size(x, 2)
    t = Array{Char}(undef, n, m)
    fill!(t,'*')
    
    for i in 1:n
        for j in 1:m
            for k in 1:6
                if JuMP.value(x[i, j, k]) > TOL
                    t[i, j] = cellType(k)
                end
            end
        end 
    end
    println(t)
    # Write the solution
    writeSolution(fout, t)
end



"""
Write a solution in an output stream

Arguments
- fout: the output stream (usually an output file)
- t: 2-dimensional array of size n*n
"""
function writeSolution(fout::IOStream, t::Array{Char, 2})
    
    println(fout, "t = [")
    n = size(t, 1)
    m = size(t, 2)
    for l in 1:n

        print(fout, "[ ")
        
        for c in 1:m
            print(fout,"'")
            print(fout,t[l, c])
            print(fout,"' ")
        end 

        endLine = "]"

        if l != n
            endLine *= ";"
        end

        println(fout, endLine)
    end

    println(fout, "]")
    
    
end 

"""
Create a pdf file which contains a performance diagram associated to the results of the ../res folder
Display one curve for each subfolder of the ../res folder.

Arguments
- outputFile: path of the output file

Prerequisites:
- Each subfolder must contain text files
- Each text file correspond to the resolution of one instance
- Each text file contains a variable "solveTime" and a variable "isOptimal"
"""
function performanceDiagram(outputFile::String)

    resultFolder = "../res/"
    
    # Maximal number of files in a subfolder
    maxSize = 0

    # Number of subfolders
    subfolderCount = 0

    folderName = Array{String, 1}()

    # For each file in the result folder
    for file in readdir(resultFolder)

        path = resultFolder * file
        
        # If it is a subfolder
        if isdir(path)
            
            folderName = vcat(folderName, file)
             
            subfolderCount += 1
            folderSize = size(readdir(path), 1)

            if maxSize < folderSize
                maxSize = folderSize
            end
        end
    end

    # Array that will contain the resolution times (one line for each subfolder)
    results = Array{Float64}(undef, subfolderCount, maxSize)

    for i in 1:subfolderCount
        for j in 1:maxSize
            results[i, j] = Inf
        end
    end

    folderCount = 0
    maxSolveTime = 0

    # For each subfolder
    for file in readdir(resultFolder)
            
        path = resultFolder * file
        
        if isdir(path)

            folderCount += 1
            fileCount = 0

            # For each text file in the subfolder
            for resultFile in filter(x->occursin(".txt", x), readdir(path))

                fileCount += 1
                include(path * "/" * resultFile)

                if isOptimal
                    results[folderCount, fileCount] = solveTime

                    if solveTime > maxSolveTime
                        maxSolveTime = solveTime
                    end 
                end 
            end 
        end
    end 

    # Sort each row increasingly
    results = sort(results, dims=2)

    println("Max solve time: ", maxSolveTime)

    # For each line to plot
    for dim in 1: size(results, 1)

        x = Array{Float64, 1}()
        y = Array{Float64, 1}()

        # x coordinate of the previous inflexion point
        previousX = 0
        previousY = 0

        append!(x, previousX)
        append!(y, previousY)
            
        # Current position in the line
        currentId = 1

        # While the end of the line is not reached 
        while currentId != size(results, 2) && results[dim, currentId] != Inf

            # Number of elements which have the value previousX
            identicalValues = 1

             # While the value is the same
            while results[dim, currentId] == previousX && currentId <= size(results, 2)
                currentId += 1
                identicalValues += 1
            end

            # Add the proper points
            append!(x, previousX)
            append!(y, currentId - 1)

            if results[dim, currentId] != Inf
                append!(x, results[dim, currentId])
                append!(y, currentId - 1)
            end
            
            previousX = results[dim, currentId]
            previousY = currentId - 1
            
        end

        append!(x, maxSolveTime)
        append!(y, currentId - 1)

        # If it is the first subfolder
        if dim == 1

            # Draw a new plot
            plot(x, y, label = folderName[dim], legend = :bottomright, xaxis = "Time (s)", yaxis = "Solved instances",linewidth=3)

        # Otherwise 
        else
            # Add the new curve to the created plot
            savefig(plot!(x, y, label = folderName[dim], linewidth=3), outputFile)
        end 
    end
end 

"""
Create a latex file which contains an array with the results of the ../res folder.
Each subfolder of the ../res folder contains the results of a resolution method.

Arguments
- outputFile: path of the output file

Prerequisites:
- Each subfolder must contain text files
- Each text file correspond to the resolution of one instance
- Each text file contains a variable "solveTime" and a variable "isOptimal"
"""
function resultsArray(outputFile::String)
    
    resultFolder = "../res/"
    dataFolder = "../data/"
    
    # Maximal number of files in a subfolder
    maxSize = 0

    # Number of subfolders
    subfolderCount = 0

    # Open the latex output file
    fout = open(outputFile, "w")

    # Print the latex file output
    println(fout, raw"""\documentclass{article}

\usepackage[french]{babel}
\usepackage [utf8] {inputenc} % utf-8 / latin1 
\usepackage{multicol}

\setlength{\hoffset}{-18pt}
\setlength{\oddsidemargin}{0pt} % Marge gauche sur pages impaires
\setlength{\evensidemargin}{9pt} % Marge gauche sur pages paires
\setlength{\marginparwidth}{54pt} % Largeur de note dans la marge
\setlength{\textwidth}{481pt} % Largeur de la zone de texte (17cm)
\setlength{\voffset}{-18pt} % Bon pour DOS
\setlength{\marginparsep}{7pt} % Séparation de la marge
\setlength{\topmargin}{0pt} % Pas de marge en haut
\setlength{\headheight}{13pt} % Haut de page
\setlength{\headsep}{10pt} % Entre le haut de page et le texte
\setlength{\footskip}{27pt} % Bas de page + séparation
\setlength{\textheight}{668pt} % Hauteur de la zone de texte (25cm)

\begin{document}""")

    header = raw"""
\begin{center}
\renewcommand{\arraystretch}{1.4} 
 \begin{tabular}{l"""

    # Name of the subfolder of the result folder (i.e, the resolution methods used)
    folderName = Array{String, 1}()

    # List of all the instances solved by at least one resolution method
    solvedInstances = Array{String, 1}()

    # For each file in the result folder
    for file in readdir(resultFolder)

        path = resultFolder * file
        
        # If it is a subfolder
        if isdir(path)

            # Add its name to the folder list
            folderName = vcat(folderName, file)
             
            subfolderCount += 1
            folderSize = size(readdir(path), 1)

            # Add all its files in the solvedInstances array
            for file2 in filter(x->occursin(".txt", x), readdir(path))
                solvedInstances = vcat(solvedInstances, file2)
            end 

            if maxSize < folderSize
                maxSize = folderSize
            end
        end
    end

    # Only keep one string for each instance solved
    unique(solvedInstances)

    # For each resolution method, add two columns in the array
    for folder in folderName
        header *= "rr"
    end

    header *= "}\n\t\\hline\n"

    # Create the header line which contains the methods name
    for folder in folderName
        header *= " & \\multicolumn{2}{c}{\\textbf{" * folder * "}}"
    end

    header *= "\\\\\n\\textbf{Instance} "

    # Create the second header line with the content of the result columns
    for folder in folderName
        header *= " & \\textbf{Temps (s)} & \\textbf{Optimal ?} "
    end

    header *= "\\\\\\hline\n"

    footer = raw"""\hline\end{tabular}
\end{center}

"""
    println(fout, header)

    # On each page an array will contain at most maxInstancePerPage lines with results
    maxInstancePerPage = 30
    id = 1

    # For each solved files
    for solvedInstance in solvedInstances

        # If we do not start a new array on a new page
        if rem(id, maxInstancePerPage) == 0
            println(fout, footer, "\\newpage")
            println(fout, header)
        end 

        # Replace the potential underscores '_' in file names
        print(fout, replace(solvedInstance, "_" => "\\_"))

        # For each resolution method
        for method in folderName

            path = resultFolder * method * "/" * solvedInstance

            # If the instance has been solved by this method
            if isfile(path)

                include(path)

                println(fout, " & ", round(solveTime, digits=2), " & ")

                if isOptimal
                    println(fout, "\$\\times\$")
                end 
                
            # If the instance has not been solved by this method
            else
                println(fout, " & - & - ")
            end
        end

        println(fout, "\\\\")

        id += 1
    end

    # Print the end of the latex file
    println(fout, footer)

    println(fout, "\\end{document}")

    close(fout)
    
end 
