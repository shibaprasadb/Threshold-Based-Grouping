library(ompr)
library(ompr.roi)
library(ROI.plugin.glpk)

element_ids <- 1:30
element_ids[!element_ids %in% c(2,6,20,23, 11, 49,60)]-> element_ids

# Define your element ids and the difference
#element_ids <- c(1, 2, 3, 4, 5, 6, 7, 88, 10, 12, 14, 93)
diff <- 5


model <- MIPModel() %>%
  # Binary variable for each element id and group
  add_variable(x[i, g], i = 1:length(element_ids), g = 1:length(element_ids), type = "binary") %>%
  # Binary variable for each group
  add_variable(y[g], g = 1:length(element_ids), type = "binary") %>%
  # Objective: minimize the number of groups
  set_objective(sum_expr(y[g], g = 1:length(element_ids)), "min") %>%
  # Constraint: each element id must be in exactly one group
  add_constraint(sum_expr(x[i, g], g = 1:length(element_ids)) == 1, i = 1:length(element_ids)) %>%
  add_constraint(y[g] <= y[g - 1], g = 2:length(element_ids)) %>%
  # Constraint: if a group is used, then y[g] = 1
  add_constraint(x[i, g] <= y[g], i = 1:length(element_ids), g = 1:length(element_ids))

# Constraint: no two element ids in the same group can have a difference equal to 'diff'
for (i in 1:(length(element_ids) - 1)) {
  for (j in (i + 1):length(element_ids)) {
    if (element_ids[j] - element_ids[i] > diff) {
      model <- model %>%
        add_constraint(x[i, g] + x[j, g] <= 1, g = 1:length(element_ids))
    }
  }
}

# Solve the model
result <- solve_model(model, with_ROI(solver = "glpk", verbose = TRUE))

# Print the solution
solution <- result %>% get_solution(x[i, g]) %>% filter(value > 0)
print(solution)