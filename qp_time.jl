using JuMP, Ipopt

# Create a new model, specifying the Ipopt solver
model = Model(Ipopt.Optimizer)

# Define time periods
T = 1:3

# Define variable x indexed over T
@variable(model, x[T])

# Add objective
@NLobjective(model, Min, sum(x[t]^2 for t in T))

# Add constraints for each time period
for t in T
    @constraint(model, x[t] + t >= 2)
end

# Solve the problem
optimize!(model)

# Print the optimal solutions for each time period
println("Optimal Solutions:")
for t in T
    println("x_$t = ", value(x[t]))
end

using Plots

# Plotting the results
plot(T, [value(x[t]) for t in T], label="x(t)", marker=:circle, linewidth=2)
xlabel!("Time Period (t)")
ylabel!("x")
title!("Optimal x over Time")
