using JuMP
using Plots
import GR


function readInputFile(inputFile::String)

    # Open the input file
    datafile = open(inputFile)

    data = readlines(datafile)
    close(datafile)
    
    n = length(data)
    m = length(split(data[1], ","))
    t = Array{Char}(undef, n, m)
    fill!(t,' ')

    lineNb = 1

    # For each line of the input file
    for line in data

        lineSplit = split(line, ",")
        if size(lineSplit, 1) == n
            for colNb in 1:n

                if lineSplit[colNb] != " "
                    t[lineNb, colNb] = Char( parse(Int64, lineSplit[colNb]) +48  )
                end
            end
        end 
        
        lineNb += 1
    end

    return t

end

function displayGrid(t::Array{Char,2})
    height = size(t,1)
    width = size(t,2)
    
    xHeight = height +1
    xWidth =  width

    zHeight = height
    zWidth = width + 1

    println("")
    for i in 1:height
        for j in 1:xWidth
            print(".  ")
        end
        println(".")
        for j in 1:zWidth
            print("  ")
            if(j<=width)
                print(t[i,j])
            end
        end
        println("")
    
        
    end
    for j in 1:xWidth
        print(".  ")
    end
    println(".")
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

function saveInstance(t::Array{Char, 2}, outputFile::String)

    n = size(t, 1)
    m = size(t,2)

    # Open the output file
    writer = open(outputFile, "w")

    # For each cell (l, c) of the grid
    for l in 1:n
        for c in 1:m

            # Write its value   
            print(writer, t[l, c])

            if c != n
                print(writer, ",")
            else
                println(writer, "")
            end
        end
    end

    close(writer)
    
end

function writeSolution(fout::IOStream, x::Array{VariableRef,2},z::Array{VariableRef,2})

    # Convert the solution from x[i, j, k] variables into t[i, j] variables

    height = size(z,1)
    width = size(x,2)
    
    xHeight = height +1
    xWidth =  width

    zHeight = height
    zWidth = width + 1

    ansX = Array{Int}(undef,xHeight,xWidth)
    ansZ = Array{Int}(undef,zHeight,zWidth)

    fill!(ansX,0)
    fill!(ansZ,0)

    
    for l in 1:xHeight
        for c in 1:xWidth
            if(JuMP.value(x[l,c])> TOL)
                ansX[l,c] = 1
            else
                ansX[l,c] = 0
            end
        end 
    end

    for l in 1:zHeight
        for c in 1:zWidth
            if(JuMP.value(z[l,c])> TOL)
                ansZ[l,c] = 1
            else
                ansZ[l,c] = 0
            end
        end 
    end

    # Write the solution
    writeSolution(fout, ansX,ansZ)

end


function writeSolution(fout::IOStream, x::Array{Int64, 2},z::Array{Int64, 2})
    
    println(fout, "x = [")
    n = size(z, 1)
    m = size(x,2)

    
    for l in 1:n+1
        print(fout, "[ ")
        for c in 1:m
            print(fout,x[l, c], " ")
        end 
        endLine = "]"

        if l != n+1
            endLine *= ";"
        end
        println(fout, endLine)
    end
    println(fout, "]")

    println(fout, "z = [")
    for l in 1:n
        print(fout, "[ ")
        for c in 1:m+1
            print(fout, z[l, c], " ")
        end 
        endLine = "]"

        if l != n+1
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