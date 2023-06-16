using JuMP, Ipopt

# Create a new model, specifying the Ipopt solver
model = Model(Ipopt.Optimizer)

# Define time periods
T = 1:3

# Define variable x and y indexed over T
@variable(model, x[T])
@variable(model, y[T])

# Add objective
@NLobjective(model, Min, sum(x[t]^2 + y[t]^2 for t in T))

# Add constraints for each time period
for t in T
    @constraint(model, x[t] + y[t] + t >= 2)
    @constraint(model, y[t] - x[t] <= 1)
end

# Solve the problem
optimize!(model)

# Print the optimal solutions for each time period
println("Optimal Solutions:")
for t in T
    println("x_$t = ", value(x[t]))
    println("y_$t = ", value(y[t]))
end

using Plots

# Plotting the results
plot(T, [value(x[t]) for t in T], label="x(t)", marker=:circle, linewidth=2)
plot!(T, [value(y[t]) for t in T], label="y(t)", marker=:circle, linewidth=2)
xlabel!("Time Period (t)")
ylabel!("Value")
title!("Optimal x and y over Time")
