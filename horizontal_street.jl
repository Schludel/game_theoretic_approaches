using JuMP, Cbc

# Create a new model
model = Model(Cbc.Optimizer)

# Define the grid size and time steps
N = 10
T = 1:10  

# Define decision variables: positions
@variable(model, x[0:N, 0:N, T], Bin)

# Initialize the position of the car
@constraint(model, x[0, 5, 1] == 1)


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

# Add street constraints: restrict car movement outside the street
for t in T[1:end-1]
    for i in 0:N
        for j in 0:N
            if j < 4 || j > 6
                @constraint(model, x[i, j, t] <= sum(x[i + di, j, t+1] for di in -1:1 if i + di in 0:N))
            end
        end
    end
end

# Define the objective: minimize the distance to (10, 5)
@objective(model, Min, sum(sqrt((i-10)^2 + (j-5)^2)*x[i, j, length(T)] for i in 0:N for j in 0:N))

# Solve the problem
optimize!(model)

# Extract the solution
solution = [(i, j, t) for i in 0:N for j in 0:N for t in T if value(x[i, j, t]) > 0.5]
println(solution)

using Plots

# Split the solution into x, y, and t coordinates
solution_x = [coord[1] for coord in solution]
solution_y = [coord[2] for coord in solution]
solution_t = [coord[3] for coord in solution]

# Create a scatter plot
p = scatter(solution_x, solution_y, zcolor=solution_t, color=:viridis,
            xlim=(0, 10), ylim=(0, 10), aspect_ratio=:equal,
            xlabel="X Position", ylabel="Y Position",
            title="Car movement over time",
            label="Car position")

# Plot the street lines
street_y1 = 4
street_y2 = 6
street_x = 0:10
plot!(collect(street_x), fill(street_y1, length(street_x)), line=:stick, color=:black, label="Street")
plot!(collect(street_x), fill(street_y2, length(street_x)), line=:stick, color=:black)



# Save the plot as a PNG file
savefig(p, "car_movement_street_plot.png")



