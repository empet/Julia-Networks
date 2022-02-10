
using PlotlyJS

function get_plotly_data(E::Vector{Tuple}, 
                   xcoord::Vector{T}, ycoord::Vector{T}) where T <: Real

    
    # E: Vector of tuples representing the graph edges
    # xcoords, ycoords: Vector(s) of node coordinates returned by a graph layout
    
    Xedges = Float64[]
    Yedges = Float64[]
    for e in E
        append!(Xedges, [xcoord[e[1]], xcoord[e[2]], NaN])
        append!(Yedges, [ycoord[e[1]], ycoord[e[2]], NaN])
    end
    return Xedges, Yedges
end;

function get_node_trace(x::Vector{T}, y::Vector{T}, labels::Vector{String};  
                   marker_size=5, marker_color="#6959CD",
                   linecolor="rgb(50,50,50)", linewidth=0.5) where T <: Real

    return PlotlyJS.scatter(
                x=x,
                y=y,
                mode="markers",
                marker=attr(
                            size=marker_size,
                            color=marker_color,
                            line=attr(color=linecolor, width=linewidth)
                             ),
                text=labels,
                hoverinfo="text")
end;

function get_edge_trace(xedge::Vector{T}, yedge::Vector{T}; 
                 linecolor="rgb(210,210,210)", linewidth=1) where T <: Real
    return PlotlyJS.scatter(
                x=xedge,
                y=yedge,
                mode="lines",
                line_color=linecolor,
                line_width=linewidth,
                hoverinfo="none"
               )
end;  

function perfect_balanced_tree_edges(;bn=2, h=6)

    # bn:  branching number; each node has bn children
    # h: the tree height, i.e. each leave is at the distance h of the tree root
    # returns the edges of such a tree
    

    if bn == 1 
        n = h+1 
    else  
       n = (bn^(h + 1)-1) ÷ (bn -1)
    end

    nodes = 1:n
    k = 1
    parents = [nodes[k]]
    edges = Tuple[]

    while !isempty(parents)
        s = popfirst!(parents)
        for _ in 1:bn
            k += 1
            if k <= n
                push!(parents, nodes[k])
                push!(edges, (s, k))
            else
                break
            end 
        end
    end
    return edges
end; 


function  Bezier_edges(xc::Vector{T}, yc::Vector{T},  
                edges::Vector{Tuple{Int, Int}};
                linewidth=1.5, linecolor="rgb(210, 210, 210)") where T <: Real
     
    shapes =  []
    for e in edges[1:end]
        #set the coordinates of the Bezier control points d_i(xi, yi),
        #for the cubic Bezier representing a tree edge
        x1 = xc[e[1]] 
        y1 = yc[e[1]]
        d1 = sqrt(x1^2 + y1^2)
        x4 = xc[e[2]] 
        y4 = yc[e[2]] 
        d4 = sqrt(x4^2 + y4^2)
        d = 0.5*(d1+d4)
        if d1 == 0 || d4 == 0 # if the first Bezier  control point is  the  root, def edge as a segment of line
            x2 = x1
            y2 = y1
            x3 = x4
            y3 = 0.3*y1 + 0.7*y4
        else   
            x2 = d*x1/d1
            y2 = d*y1/d1
            x3 = d*x4/d4
            y3 = d*y4/d4
        end       
        push!(shapes, attr(type="path",
                           layer="below",
                           path= "M $x1 $y1, C $x2 $y2, $x3 $y3, $x4  $y4",
                           line=attr(color=linecolor, width=linewidth)
                                ))
    end
    return shapes
end;   
      
function proj2circle(xpos::Vector{T}, ypos::Vector{T}; 
                dirfactor=-1,  θ₀=-π/2) where T <: Real
    
    xmin, xmax = extrema(xpos)
    ymin, ymax = extrema(ypos)
    θ = 2π*(xpos .- xmin)/(xmax-xmin) .+ θ₀
    r = ymax .-  ypos
    xc = r .* cos.(θ)
    yc = dirfactor * r .* sin.(θ)
    return xc, yc
end;

