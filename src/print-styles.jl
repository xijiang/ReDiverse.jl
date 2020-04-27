# The color plan below is better in terminal dark mode

"""
    print_sst(msg::AbstractString)
---
If there are several parts in a function, this function print a title of bold
light blue.
"""
function print_sst(msg::AbstractString)
    printstyled('\n', msg, '\n', bold = true, color = :light_blue)
    printstyled(repeat('=', length(msg)), '\n', color=:light_blue)
end

"""
    print_msg(msg::AbstractString)
---
This function print the msg as soft warning, i.e., the text color is of :light_magenta
"""
function print_msg(msg::AbstractString)
    println()
    printstyled('\n', msg, '\n'; color = :light_magenta)
end

"""
    print_desc(msg::AbstractString)

---
This is to print some descriptions of results that are going to be showed below the
description.
This function print the message, a newline, and in color :yellow.
"""
function print_desc(msg::AbstractString)
    printstyled(msg, '\n'; color=:yellow)
end

"""
    print_done()
---
Print message `Done` in light_green.
"""
function print_done()
    printstyled("\n...Done\n"; color=:light_green)
end

"""
    print_item(item::AbstractString)
---
Print an item under print_sst(msg).
"""
function print_item(item::AbstractString)
    printstyled("\n- $item\n"; color=74)
end
