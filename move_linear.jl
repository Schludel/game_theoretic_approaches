using JuMP, Cbc

# Create a new model
model = Model(Cbc.Optimizer)

# Define the grid size and time steps
N = 10
T = 1:10  

# Define decision variables: positions
@variable(model, x[0:N, 0:N, T], Bin)

# Initialize the position of the car
@constraint(model, x[0, 0, 1] == 1)

# Add obstacle at (5,5)
@constraint(model, sum(x[5, 5, t] for t in T) == 0)

# Add obstacle at (5,5)
@constraint(model, sum(x[3, 5, t] for t in T) == 0)

# Add movement constraints, allowing for horizontal and vertical moves
for t in T[1:end-1]
    for i in 0:N
        for j in 0:N
            movement = @expression(model, sum(x[i + di, j + dj, t + 1] for di in -1:1 for dj in -1:1 if i + di in 0:N && j + dj in 0:N))
            @constraint(model, x[i, j, t] <= movement)
        end
    end
end

# Add location constraints: the car can be at one and only one place at any time
for t in T
    @constraint(model, sum(x[i, j, t] for i in 0:N for j in 0:N) == 1)
end

# Define the objective: minimize the distance to (10, 10)
@objective(model, Min, sum(sqrt((i-10)^2 + (j-10)^2)*x[i, j, length(T)] for i in 0:N for j in 0:N))

# Solve the problem
optimize!(model)

# Extract the solution
solution = [(i, j, t) for i in 0:N for j in 0:N for t in T if value(x[i, j, t]) > 0.5]
println(solution)


using Plots

# Split the solution into x, y and t coordinates
solution_x = [coord[1] for coord in solution]
solution_y = [coord[2] for coord in solution]
solution_t = [coord[3] for coord in solution]

# Create a scatter plot
p = scatter(solution_x, solution_y, zcolor=solution_t, color=:viridis,
            xlabel="X Position", ylabel="Y Position", 
            title="Car movement over time",
            label="Car position")

# Add the obstacles to the plot
scatter!(p, [5], [5], markersize=10, color=:red, label="Obstacle 1")
scatter!(p, [3], [5], markersize=10, color=:blue, label="Obstacle 2")

# Save the plot as a PNG file
#savefig(p, "car_movement_plot.png")
