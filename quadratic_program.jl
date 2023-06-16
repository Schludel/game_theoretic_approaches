using Plots

# Define the objective function
f(x,y) = x^2 + 2*y^2 - 3*x - 4*y + 1

# Generate a range of values for x and y
x_vals = -2:0.1:2
y_vals = -2:0.1:2

# Generate the contour plot
p = contour(x_vals, y_vals, f, framestyle=:box, levels=50, c=cgrad(:viridis), legend=false, size=(500,500))

# Mark the feasible region
plot!(x_vals, [max(1-x, -2) for x in x_vals], fill=(0, :lightgrey, 0.5), label="Feasible Region")

# Solve the problem again (as in your previous code)
using JuMP, Ipopt
model = Model(Ipopt.Optimizer)
@variable(model, x)
@variable(model, y)
@NLobjective(model, Min, x^2 + 2*y^2 - 3*x - 4*y + 1)
@constraint(model, x + y >= 1)
@constraint(model, x - y <= 2)
optimize!(model)

# Get the optimal solution
x_star, y_star = value(x), value(y)

println("Optimal Solutions:")
println("x = ", x_star)
println("y = ", y_star)

# Mark the optimal solution
scatter!([x_star], [y_star], color=:red, label="Optimal Solution")

# Display the plot
display(p)

