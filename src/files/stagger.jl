function apply_stagger(grid, ::Val{CellCentre})
    n = length(grid)
    if n == 1
        (midpoints(grid[1]),)
    elseif n == 2
        (midpoints(grid[1]), midpoints(grid[2]))
    else
        (midpoints(grid[1]), midpoints(grid[2]), midpoints(grid[3]))
    end
end

function apply_stagger(grid, ::Val{FaceX})
    n = length(grid)
    if n == 1
        (grid[1],)
    elseif n == 2
        (grid[1], midpoints(grid[2]))
    else
        (grid[1], midpoints(grid[2]), midpoints(grid[3]))
    end
end

function apply_stagger(grid, ::Val{FaceY})
    n = length(grid)
    if n == 1
        (midpoints(grid[1]),)
    elseif n == 2
        (midpoints(grid[1]), grid[2])
    else
        (midpoints(grid[1]), grid[2], midpoints(grid[3]))
    end
end

function apply_stagger(grid, ::Val{FaceZ})
    n = length(grid)
    if n == 1
        (midpoints(grid[1]),)
    elseif n == 2
        (midpoints(grid[1]), midpoints(grid[2]))
    else
        (midpoints(grid[1]), midpoints(grid[2]), grid[3])
    end
end

function apply_stagger(grid, ::Val{EdgeX})
    n = length(grid)
    if n == 1
        (midpoints(grid[1]),)
    elseif n == 2
        (midpoints(grid[1]), grid[2])
    else
        (midpoints(grid[1]), grid[2], grid[3])
    end
end

function apply_stagger(grid, ::Val{EdgeY})
    n = length(grid)
    if n == 1
        (grid[1],)
    elseif n == 2
        (grid[1], midpoints(grid[2]))
    else
        (grid[1], midpoints(grid[2]), grid[3])
    end
end

function apply_stagger(grid, ::Val{EdgeZ})
    n = length(grid)
    if n == 1
        (grid[1],)
    elseif n == 2
        (grid[1], grid[2])
    else
        (grid[1], grid[2], midpoints(grid[3]))
    end
end

function apply_stagger(grid, ::Val{Vertex})
    n = length(grid)
    if n == 1
        (grid[1],)
    elseif n == 2
        (grid[1], grid[2])
    else
        (grid[1], grid[2], grid[3])
    end
end
