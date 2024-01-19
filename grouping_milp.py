import pandas as pd
from pulp import *
from docplex import *


# Define your element ids and the difference
element_ids = list(range(1, 40))
exclude_elements = [2, 6, 20, 23, 11, 49, 60]
element_ids = [i for i in element_ids if i not in exclude_elements]
diff = 5

# Create the 'prob' variable to contain the problem data
prob = LpProblem("Grouping Problem", LpMinimize)

# Create binary variables for each element id and group
x = LpVariable.dicts("x", (range(len(element_ids)), range(len(element_ids))), cat='Binary')

# Create binary variables for each group
y = LpVariable.dicts("y", range(len(element_ids)), cat='Binary')

# Objective: minimize the number of groups
prob += lpSum(y[g] for g in range(len(element_ids)))

# Constraint: each element id must be in exactly one group
for i in range(len(element_ids)):
    prob += lpSum(x[i][g] for g in range(len(element_ids))) == 1

# Constraint: if a group is used, then y[g] = 1
for i in range(len(element_ids)):
    for g in range(len(element_ids)):
        prob += x[i][g] <= y[g]

# Constraint: groups must be used in order
#for g in range(1, len(element_ids)):
#    prob += y[g] <= y[g - 1]

# Constraint: no two element ids in the same group can have a difference equal to 'diff'
for i in range(len(element_ids) - 1):
    for j in range(i + 1, len(element_ids)):
        if element_ids[j] - element_ids[i] > diff:
            for g in range(len(element_ids)):
                prob += x[i][g] + x[j][g] <= 1

# Solve the problem
prob.solve(PULP_CBC_CMD(msg=True))

# Print the solution
for i in range(len(element_ids)):
    for g in range(len(element_ids)):
        if value(x[i][g]) > 0:
            print(f"Element {element_ids[i]} is in group {g}")

