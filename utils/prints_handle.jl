export repl_matrix_with_comment

# creating a function to print the matrix with comments on the right side of the output 
function repl_matrix_with_comment(M::AbstractMatrix; comments::Dict{Int,String} = Dict{Int, String}())
    txt = sprint(io->show(io, MIME("text/plain"), M))
    txt = replace(txt, "true" => "1")
    txt = replace(txt, "false" => "0")
    txt = replace(txt, "//" => "/")
    txt = replace(txt, "/1" => "")
    lines = split(txt, '\n', keepempty=false)
    for (k,v) in comments
        if 1 <= k <= length(lines) && !isempty(v)
            # +1 because the first line of the matrix output is the header
            lines[k+1] *= "  --> " * v
        end
    end
    return join(lines, '\n')
end