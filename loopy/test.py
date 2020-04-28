import linearPorgraming as lp
import heuristic as hc
import inputOutput as io
import generate








grid = generate.generateInstanc()
a,b,c = lp.cplexSolve(grid)
io.displaySolution(grid,b[0],b[1])
print(c)
print("-----------------------------------")
a,b,c = hc.heuristicSolve(grid)
io.displaySolution(grid,b[0],b[1])
print(c)