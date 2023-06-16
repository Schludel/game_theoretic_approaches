using JuMP, Ipopt

# Create a new model, specifying the Ipopt solver
model = Model(Ipopt.Optimizer)

# Define time periods and products
T = 1:3
products = [:A, :B]

# Define quantity variables for each product in each time period
@variable(model, q[products,T] >= 0)

# Define costs (arbitrary)
costs = Dict(:A => 2, :B => 3)

# Add objective: minimize total cost over all time periods
@NLobjective(model, Min, sum(costs[product] * q[product,t]^2 for product in products for t in T))

# Add constraints
for t in T
    @constraint(model, q[:A,t] + 2*q[:B,t] >= 100)  # Demand constraint
    @constraint(model, q[:B,t] <= 2*q[:A,t])        # Production constraint
    @constraint(model, sum(q[product,t] for product in products) <= 150)  # Total production constraint
end

# Solve the problem
optimize!(model)

# Print the optimal solutions for each time period
println("Optimal Production Quantities:")
for t in T
    for product in products
        println("q_$(product)_$t = ", value(q[product,t]))
    end
end

using Plots

# Plotting the results
plot(T, [value(q[:A,t]) for t in T], label="Product A", marker=:circle, linewidth=2)
plot!(T, [value(q[:B,t]) for t in T], label="Product B", marker=:circle, linewidth=2)
xlabel!("Time Period (t)")
ylabel!("Production Quantity")
title!("Optimal Production Quantities over Time")
