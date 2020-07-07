export FileInfo

const FileInfo = Dict{String,String}

function pause() 
  a = readline()
  (length(a) == 0) && return
  (a[1]=='q') && exit(0)
end

function get_arg(args,
                 key,
                 default=nothing)
  if haskey(args,key)
    return args[key]
  end
  if isnothing(default)
    throw(ArgumentError("key $key not found in argument dictionary"))
  end
  return default
end
